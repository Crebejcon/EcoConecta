-- EcoConecta: execute este arquivo no SQL Editor do Supabase.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.collection_points (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null,
  neighborhood text,
  address text not null,
  materials text,
  map_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.electronics (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  device_type text not null,
  quantity integer not null check (quantity between 1 and 100),
  condition text not null,
  city text not null,
  neighborhood text,
  notes text,
  status text not null default 'Recebido'
    check (status in ('Recebido','Em análise','Aguardando entrega','Concluído','Cancelado')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  message text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data ->> 'full_name', new.email);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

create or replace function public.notify_electronics_status()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if new.status is distinct from old.status then
    insert into public.notifications(user_id,title,message)
    values (new.user_id,'Atualização do descarte',
      'O status do seu registro de ' || new.device_type || ' mudou para: ' || new.status || '.');
    new.updated_at = now();
  end if;
  return new;
end;
$$;

drop trigger if exists electronics_status_notification on public.electronics;
create trigger electronics_status_notification before update of status on public.electronics
for each row execute procedure public.notify_electronics_status();

alter table public.profiles enable row level security;
alter table public.collection_points enable row level security;
alter table public.electronics enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "profile read own or admin" on public.profiles;
create policy "profile read own or admin" on public.profiles for select
using (id = (select auth.uid()) or public.is_admin());

drop policy if exists "profile update own name" on public.profiles;
create policy "profile update own name" on public.profiles for update
using (id = (select auth.uid())) with check (id = (select auth.uid()) and role = 'user');

drop policy if exists "public reads active collection points" on public.collection_points;
create policy "public reads active collection points" on public.collection_points for select
using (active = true or public.is_admin());

drop policy if exists "admin manages collection points" on public.collection_points;
create policy "admin manages collection points" on public.collection_points for all
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "users create own electronics" on public.electronics;
create policy "users create own electronics" on public.electronics for insert
with check (user_id = (select auth.uid()));

drop policy if exists "users read own electronics or admin" on public.electronics;
create policy "users read own electronics or admin" on public.electronics for select
using (user_id = (select auth.uid()) or public.is_admin());

drop policy if exists "admin updates electronics" on public.electronics;
create policy "admin updates electronics" on public.electronics for update
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "users read own notifications" on public.notifications;
create policy "users read own notifications" on public.notifications for select
using (user_id = (select auth.uid()));

drop policy if exists "users mark own notifications read" on public.notifications;
create policy "users mark own notifications read" on public.notifications for update
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Depois de criar sua conta, copie o UUID em Authentication > Users
-- e execute o comando abaixo substituindo SEU-UUID:
-- update public.profiles set role = 'admin' where id = 'SEU-UUID';
-- Nunca permita que o formulário público escolha ou altere o campo role.