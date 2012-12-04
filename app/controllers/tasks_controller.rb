class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    unless params[:application_id].nil?
      @task = Application.find(params[:application_id]).tasks.build
    else
      @task = Task.new
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    return error_404 if params[:application_id].nil? and params[:task].nil?

    if not params[:application_id].nil?
      application_id = params[:application_id]
    else
      application_id = params[:task][:application_id]
    end

    application = Application.find(application_id)
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
