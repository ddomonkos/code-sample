class CreateEvent
  include UseCase

  attr_reader :event

  def initialize(attrs = {})
    @attrs = attrs
  end

  def perform
    @event = Event.new(attrs.merge(created_by: current_user))
    authorize! :create, event

    if event.save
      if event.group
        NotificationService.notify(
          audience: event.group.members - [current_user],
          template: {
            subject: event.created_by,
            object: event,
            kind: :group_event_created
          }
        )
      else
        event.participants << event.created_by
      end
      Right.find_or_create_by(user: event.created_by, object: event, kind: Right::MANAGE)
    else
      raise ValidationError.new(event)
    end
  end

  protected

  attr_reader :attrs
end
