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
      add :state, :jsonb
      timestamps
    end

    create table(:task_dependencies, primary_key: false) do
      add :task, references(:task, type: :uuid), primary_key: true
      add :dependency, references(:task, type: :uuid), primary_key: true
      timestamps
    end
  end
end
