use Mix.Config

# Default database URL.
url = "postgres://grit:grit@localhost/grit"

# http://philippkueng.ch/deploy-a-phoenix-application-on-heroku.html
%{host: host, port: port, path: "/" <> database, userinfo: userinfo} =
  URI.parse(System.get_env("DATABASE_URL") || url)

[username, password] = case is_binary(userinfo) do
  true -> case userinfo |> String.split(":") do
    [username, password] -> [username, password]
    [username] -> [username, nil]
  end
  false -> [nil, nil]
end

config :grit, Grit.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: database,
  hostname: host,
  port: port || 5432,
  username: username,
  password: password
