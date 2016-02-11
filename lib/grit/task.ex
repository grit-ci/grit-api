defmodule Grit.Task do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields ~w(type status path)
  schema "task" do
    # Complete path of the task in the dependency tree.
    # See: http://www.monkeyandcrow.com/blog/hierarchies_with_postgres/
    field :path, {:array, :binary_id}

    # Time when the task most recently got popped from the queue.
    field :start, Ecto.DateTime

    # Time when the task has moved to a `status` other than "processing" or
    # "pending".
    field :end, Ecto.DateTime


    # The number of times the task has been popped from the queue.
    field :attempts, :integer, default: 0

    # The type of the task. This is the primary mechanism determining what
    # tasks _can_ be run by which runners, and what UI could look like.
    # Generally there is a unique shape to `state` for each given `type`.
    field :type, :string

    # The current status of the task.
    field :status, :string, default: "pending"

    # State is the interal blob data that the task runner uses to complete
    # the job. It could include things like git urls, tokens or the like.
    field :state, :map
    timestamps
  end
end
