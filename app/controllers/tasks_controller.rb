class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    application = Application.find(params[:application_id])
    @task = application.tasks.build
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    return error_404 if params[:application_id].nil?

    application = Application.find(params[:application_id])
    @task = application.tasks.build(params[:task])

    if @task.valid? && @task.save
      redirect_to @task, flash: { notice: "Successfully created new deploy task" }
    else
      render action: "new", flash: { alert: "There are some problems with the deploy task" }
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update_attributes(params[:task])
      redirect_to @task, flash: { notice: "Successfully updated the deploy task" }
    else
      redirect_to @task, flash: { alert: "There are some problems with the deploy task" }
    end
  end
end
