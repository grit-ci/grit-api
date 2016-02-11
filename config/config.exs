use Mix.Config

# http://philippkueng.ch/deploy-a-phoenix-application-on-heroku.html
%{host: host, port: port, path: "/" <> database, userinfo: userinfo} =
  URI.parse(System.get_env("DATABASE_URL") || "postgres://grit:grit@localhost/grit")
[username, password] =
  if userinfo, do: userinfo |> String.split(":"), else: [nil,nil]

config :grit, Grit.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: database,
  hostname: host,
  port: port || 5432,
  username: username,
  password: password
