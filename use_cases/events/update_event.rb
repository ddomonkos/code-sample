class UpdateEvent
  include UseCase

  attr_reader :event

  def initialize(event, attrs = {})
    @event = event
    @attrs = attrs
  end

  def perform
    raise ValidationError unless event.in_future?
    authorize! :update, event

    old_date = event.date && event.date.to_time.to_i

    if event.update(attrs)
      new_date = event.date && event.date.to_time.to_i
      if new_date != old_date
        NotificationService.notify(
          audience: event.participants - [current_user],
          template: {
            subject: current_user,
            object: event,
            kind: :event_date_changed
          }
        )
      end
    else
      raise ValidationError.new(event)
    end
  end

  protected

  attr_reader :attrs
end
