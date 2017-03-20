class MarkTipSeen
  include UseCase

  def initialize(user, tip)
    @user = user
    @tip = tip
  end

  def perform
    authorize! :modify, user
    raise ValidationError unless TipsService.valid?(tip)
    TipsService.mark_seen(user, tip)
  end

  protected

  attr_reader :user, :tip
end
