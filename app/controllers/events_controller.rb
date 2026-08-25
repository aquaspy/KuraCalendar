class EventsController < ApplicationController
  rate_limit to: 60, within: 1.minute, only: :create,
    by: -> { current_user.id },
    with: -> { redirect_back fallback_location: root_path, alert: I18n.t("auth.too_many") }

  def create
    event = current_user.events.new(event_params)
    save_event(event)
  end

  def update
    event = current_user.events.find(params[:id])
    event.assign_attributes(event_params)
    save_event(event)
  end

  def destroy
    event = current_user.events.find(params[:id])
    date = event.starts_on
    event.destroy
    Event.reclaim_space
    redirect_to cal_path(date)
  end

  private
    def event_params
      params.require(:event).permit(:title, :body, :all_day, :starts_on, :ends_on, :starts_at, :ends_at)
    end

    def save_event(event)
      if event.save
        redirect_to cal_path(event.starts_on)
      else
        fallback = event.starts_on.presence || Date.current
        redirect_to cal_path(fallback), alert: event.errors.full_messages.to_sentence
      end
    end
end
