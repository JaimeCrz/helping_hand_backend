# frozen_string_literal: true

class Api::V1::TasksController < ApplicationController
  before_action :authenticate_user!, only: %i[create update]
  before_action :restrict_user_to_have_one_active_task, only: %i[create]
  before_action :find_task, only: :update

  def index
    tasks = Task.where(status: :confirmed || :claimed)
    render json: tasks
  end

  def create
    task = Task.create(task_params)
    task.task_items.create(product_id: params[:product_id])
    render json: create_json_response(task)
  end

  def update
    case params[:activity]
    when 'confirmed'
      if @task.is_confirmable?
        @task.update(status: params[:activity])
        render json: { message: 'Your task has been confirmed' }
      else
        render_error_message(@task)
      end
    when 'claimed'
      if @task.is_claimable?(current_user)
        @task.update(status: params[:activity], provider: current_user)
        render json: { message: 'You claimed the task' }
      else
        render_error_message(@task)
      end
    when 'delivered'
      if @task.is_deliverable?(current_user)
        @task.update(status: params[:activity], provider: current_user)
        render json: { message: 'Thank you for your help!' }
      else
        render_error_message(@task)
      end

    when 'finalized'
      if @task.is_finalizable?(current_user)
        @task.update(status: params[:activity], user: current_user)
        render json: { message: 'You finalized the delivery' }
      else
        render_error_message(@task)
      end

    else
      product = Product.find(params[:product_id])
      @task.task_items.create(product: product)
      render json: create_json_response(@task)
    end
  end

  private

  def task_params
    params.permit(:id, :products, :total, :long, :lat, :user_id)
  end

  def find_task
    @task = Task.find(params[:id])
  end

  def restrict_user_to_have_one_active_task
    if current_user.tasks.any? { |task| task.status == 'confirmed' }
      render json: { error: 'You can only have one active task at a time.' }, status: 403
      nil
    end
  end

  def create_json_response(task)
    json = { task: TaskSerializer.new(task) }
    json.merge!(message: 'The product has been added to your request')
  end
end
