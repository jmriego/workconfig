# Install zsh-async if it’s not present
if [[ ! -a ~/.zsh-async ]]; then
  git clone -b ‘v1.6’ git@github.com:mafredri/zsh-async ~/.zsh-async
fi
source ~/.zsh-async/async.zsh
# Initialize zsh-async
async_init
# Start a worker that will report job completion
async_start_worker prompt_worker -n
# Wrap status in a function, so we can pass in the working directory
# Define a function to process the result of the job
completed_callback() {
  local output="$3"
  H_PROMPT_GIT="$output"
  async_job prompt_worker ~/workconfig/zsh/prompt/prompt.zsh $(pwd)
}
# Register our callback function to run when the job completes
async_register_callback prompt_worker completed_callback
# Start the job
async_job prompt_worker ~/workconfig/zsh/prompt/prompt.zsh $(pwd)
