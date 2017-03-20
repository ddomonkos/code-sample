module UseCase
  extend ActiveSupport::Concern
  # include ActiveModel::Validations

  module ClassMethods
    # The perform method of a UseCase should always return itself
    def perform(*args)
      new(*args).tap { |use_case| use_case.perform }
    end
  end

  # implement all the steps required to complete this use case
  def perform
    raise NotImplementedError
  end

  # inside of perform, add errors if the use case did not succeed
  def success?
    errors.empty?
  end

  def errors
    @errors ||= []
  end

  protected

  attr_writer :errors

  def authorize!(*args)
    Context.get.authorize!(*args)
  end

  def can?(*args)
    Context.get.can?(*args)
  end

  def current_user
    Context.get.user
  end
end
