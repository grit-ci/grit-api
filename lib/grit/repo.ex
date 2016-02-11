defmodule Grit.Repo do
  use Ecto.Repo,
  otp_app: :grit
end

defmodule Grit.Task do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields ~w(type status path)
  schema "task" do
    field :start, Ecto.DateTime
    field :end, Ecto.DateTime
    field :path, {:array, :binary_id}
    field :expires, Ecto.DateTime
    field :attempts, :integer, default: 0
    field :type, :string
    field :status, :string, default: "pending"
    field :state, :map
    timestamps
  end
end

defmodule Grit.Query do
  import Ecto.Query

  # ------------------------------------------------------------------------
  # Getting Tasks
  # ------------------------------------------------------------------------

  # Get single task.
  def task(id) do
    Grit.Task
      |> where([task], task.id == ^id)
  end

  # Get all task children.
  def subtree(id) do
     Grit.Task
      |> where([task], fragment("path && ARRAY[?]", ^id))
  end

  # Get task and all its children.
  def tree(id) do
     Grit.Task
      |> where([task], fragment("path && ARRAY[?] OR id = ?", task.id, ^id))
  end

  # Get the current tasks in the work queue.
  def queue() do
    Grit.Task
      |> where([tasks], fragment("(SELECT COUNT(*) FROM task AS t WHERE t.status != 'completed' AND t.id = ANY (?) AND t.id != ?)", tasks.path, tasks.id) == 0)
      |> where([task], task.status == "pending")
      |> order_by([task], asc: task.inserted_at)
  end

  # ------------------------------------------------------------------------
  # Creating Tasks
  # ------------------------------------------------------------------------

  # Add a new task to the work queue.
  def push(state, parent) do
    id = Ecto.UUID.generate
    path = if parent, do:
      # FIXME: ecto support for inserting with [sub]query values
      # ("(SELECT path FROM task WHERE id=?) || ?::uuid)", parent, id),
      task(parent) |> select([task], task.path),
    else: [id]
    Grit.Repo.insert(%Grit.Task{
      id: id,
      status: "pending",
      state: state,
      path: path,
    })
  end

  # ------------------------------------------------------------------------
  # Updating Tasks
  # ------------------------------------------------------------------------

  # Restart the task.
  def restart(id) do
    tree(id)
      |> update(set: [status: "pending"])
      |> update(set: [reason: "restart"])
  end

  # Mark the task as cancelled.
  def cancel(id) do
    tree(id)
      |> update(set: [status: "cancelled"])
      |> where([task], task.id == ^id)
  end

  # Mark the task as having taken too long.
  def timeout(id) do
    task(id)
      |> update(set: [status: "error"])
      |> update(set: [reason: "timeout"])
      |> update(set: [end: ^Ecto.DateTime.utc])
  end

  # Complete the task.
  def complete(id) do
    task(id)
      |> update(set: [status: "completed"])
      |> update(set: [end: ^Ecto.DateTime.utc])
  end

  # Pop tasks from the work queue.
  def pop(count) do
    Grit.Task
      # FIXME: echo support for `IN` operation in [sub]queries
      |> where([task], task.id in ^(queue()
        |> select([child], child.id)
        |> limit(1)
      ))
      |> update(set: [status: "processing"])
      |> update(inc: [attempts: 1])
      |> update(set: [start: ^Ecto.DateTime.utc])
  end

  # Pop a single task from the work queue.
  def pop() do
    pop(1)
  end
end
