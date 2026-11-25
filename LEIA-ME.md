# EcoConecta

Plataforma responsiva para consulta de pontos de coleta de resíduos eletrônicos, registro de itens para descarte e acompanhamento de status.

## Arquivos
- `index.html`: estrutura da página.
- `styles.css`: visual responsivo.
- `app.js`: autenticação, registros, pontos e painel.
- `supabase-schema.sql`: tabelas, gatilhos e políticas de segurança.

## 1. Criar o banco Supabase
1. Crie um projeto no Supabase.
2. Abra **SQL Editor**.
3. Cole o conteúdo de `supabase-schema.sql` e execute.
4. Em **Project Settings > API**, copie a Project URL e a chave pública **anon/publishable**.
5. No arquivo `app.js`, substitua `COLE_A_URL_DO_SEU_PROJETO` e `COLE_A_CHAVE_ANON_PUBLIC` pelos valores do seu projeto.

A chave pública pode ficar no frontend quando as políticas RLS estão habilitadas. **Nunca coloque service_role, senha de banco ou segredo privado no GitHub.**

## 2. Criar o administrador
1. Cadastre sua conta pela página.
2. No Supabase, abra **Authentication > Users** e copie o UUID dessa conta.
3. No SQL Editor, execute:
   `update public.profiles set role = 'admin' where id = 'SEU-UUID';`
4. Saia e entre novamente no site.

O cadastro público sempre cria usuário comum. Somente alguém com acesso administrativo ao projeto Supabase pode promover uma conta para administrador.

## 3. Publicar pelo GitHub Pages
1. Abra **Settings > Pages** no repositório.
2. Em **Build and deployment**, escolha **Deploy from a branch**.
3. Selecione a branch `main` e a pasta `/(root)`.
4. Salve e aguarde a publicação.
5. No Supabase, configure a URL publicada em **Authentication > URL Configuration** como Site URL e inclua também nas Redirect URLs.

## 4. Recursos disponíveis
- Consulta pública de pontos de coleta ativos.
- Cadastro e login por e-mail e senha.
- Registro de eletrônicos e histórico individual.
- Painel administrativo para consultar registros e atualizar status.
- Cadastro de pontos de coleta pelo administrador.
- Notificação dentro do site quando o administrador altera o status de um registro.

## 5. Limites e próximos passos
Este primeiro pacote é a base funcional do **site**, não um aplicativo Android publicado. As notificações desta versão aparecem dentro da área da conta; notificações push no celular exigem integração adicional (por exemplo, Firebase Cloud Messaging e serviço seguro no servidor). Antes de uso público, configure uma política de privacidade, canal de contato, processo de exclusão de conta/dados, teste as permissões e cadastre pontos reais com autorização.

Para criar o app Android depois, o projeto precisará de uma etapa própria de desenvolvimento, testes e configuração de notificações. Não compartilhe chaves privadas ou dados pessoais no repositório público.