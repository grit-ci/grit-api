defmodule Grit.Repo.Migrations.Tasks do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE task_status AS ENUM (
      'pending',
      'processing',
      'completed',
      'errored',
      'timedout',
      'failed'
    )"

    create table(:task, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :start, :datetime
      add :end, :datetime
      add :status, :task_status
      add :type, :varchar
      add :attempts, :integer
      add :state, :jsonb
      add :path, {:array, :uuid}
      timestamps
    end
  end
end
