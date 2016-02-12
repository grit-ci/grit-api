# grit-api

API server for `grit-ci`.

![build status](http://img.shields.io/travis/grit-ci/grit-api/master.svg?style=flat)
![coverage](http://img.shields.io/coveralls/grit-ci/grit-api/master.svg?style=flat)

## Tasks

* Virtual workers in elixir that monitor specific types of tasks and automatically complete them when possible – e.g. the group type is always completed as soon as its dependencies are complete.


## Worker API
PUT task/:id (update task info e.g. status – called by worker when task completes or errors)
POST task/:id/log (add log entry – called by worker when task log data is to be added)
POST /queue/:id/pop (get a task – called by worker when it wants new work; returns complete task object necessary for processing the job)
SUBSCRIBE /queue/:id (watch for new tasks in the queue)

## Client API
POST /job (create new job + associated dependent tasks – returns full task tree)
GET /task/:id (get task information – option to return full tree)
POST /task/:id/restart (restart a task – option to cascade)
POST /task/:id/cancel (cancel a task – option to cascade)

```sh
function success() {
  curl -XPOST ${API}/task/${TASK_ID}/status
}

function failure() {
  curl -XPOST ${API}/task/${TASK_ID}/status
}


curl -XPOST ${API}/queue/${QUEUE}/pop -o job.json
if [ $? -eq 0 ]; then

  # Run the container.
  docker run lol

  # Send the logs to the task.
  tail -f container.log | xargs curl -XPOST ${API}/task/${TASK_ID}/log

  # Output results
  if [ $? -eq 0 ]; then
    success
  else
    failure
  fi
else
  sleep 10
fi
```
>>>>>>> 7ed2bd7... WIP.
