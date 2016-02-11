defmodule Grit.Repo do
  use Ecto.Repo,
  otp_app: :grit
end

defmodule Grit.TaskDependencies do
  use Ecto.Schema

  @required_fields ~w(task dependency)
  @primary_key false
  schema "task_dependencies" do
    belongs_to :task, Grit.Task, type: :binary_id, primary_key: true
    belongs_to :dependency, Grit.Task, type: :binary_id, primary_key: true
    timestamps
  end
end

defmodule Grit.Task do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields ~w(type status)
  schema "task" do
    many_to_many :dependencies, Grit.Task, join_through: "task_dependencies"
    field :start, Ecto.Date
    field :end, Ecto.Date
    field :expires, Ecto.Date
    field :reason, :string
    field :attempts, :integer
    field :type, :string
    field :status, :string, default: "pending"
    field :state, :map
    timestamps
  end
end

defmodule Grit.Query do
  import Ecto.Query

  # set this task and all child tasks to state = pending
  def restart(id) do
    Grit.Task
      |> update(set: [status: "pending"])
      |> update(set: [reason: "restart"])
      |> where([task], task.id == ^id)
  end

  # set this task and all child tasks to state = cancelled
  def cancel(id) do
    Grit.Task
      |> update(set: [status: "completed"])
      |> where([task], task.id == ^id)
  end

  def timeout(id) do
    Grit.Task
      |> update(set: [status: "error"])
      |> update(set: [reason: "timeout"])
      |> update(set: [end: ^Ecto.DateTime.utc])
      |> where([task], task.id == ^id)
  end

  # set this task to state complete
  def complete(id) do
    Grit.Task
      |> update(set: [status: "completed"])
      |> update(set: [end: ^Ecto.DateTime.utc])
      |> where([task], task.id == ^id)
  end

  # postgres notify/listen for task events
  # e.g.
  # * status change
  # * log output
  def subscribe do

  end

  # Mark a row as "processing" and assign a processing token. Only the entity
  # with the processing token can update the row, until the token expires at
  # which point the row will be updated with state "timeout". Said token will
  # be a JWT. Update the "expires" field to the same value found in the token.
  def pop(amount) do
    Grit.Task
      |> update(set: [status: "processing"])
      |> update(inc: [attempts: 1])
      |> update(set: [start: ^Ecto.DateTime.utc])
      |> where([tasks], fragment("(SELECT COUNT(d.*) FROM task_dependencies AS d LEFT JOIN task AS t ON d.dependency = t.id WHERE t.status != 'completed' AND d.task = ?)", tasks.id) == 0)
      |> where([task], task.status == "pending")
      |> limit(^amount)
  end

  # Add a new task to the queue.
  def push(state) do
    Grit.Repo.insert(%Grit.Task{
      status: "pending",
      state: state,
    })
  end

end

# def pop do
#   query = Task
#     |> update(set: [grabbed: now()])
#     |> where([t], t.id == Task
#       |> select([x], x.itemid)
#       |> where([x], is_nil(x.grabbed))
#       |> order_by(asc: :itemid)
#       |> limit(1)
#       |> lock("FOR UPDATE SKIP LOCKED")
#     )
#     |> returning(:all)
