module Api
  module V1
    class EventsController < Api::BaseController
      rate_limit to: 60, within: 1.minute, only: %i[create update],
        by: -> { current_api_token.id },
        with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

      def index
        from, to = date_range_params
        render json: { events: current_user.events.in_range(from, to).map(&:as_api) }
      rescue Date::Error, ArgumentError
        render json: { errors: [ I18n.t("api.invalid_date") ] }, status: :unprocessable_entity
      end

      def show
        event = current_user.events.find_by(id: params[:id])
        return render_not_found unless event

        render json: { event: event.as_api }
      end

      def create
        event = current_user.events.new(event_params)
        if event.save
          render json: { event: event.as_api }, status: :created
        else
          render_unprocessable(event)
        end
      end

      def update
        event = current_user.events.find_by(id: params[:id])
        return render_not_found unless event

        if event.update(event_params)
          render json: { event: event.as_api }
        else
          render_unprocessable(event)
        end
      end

      def destroy
        event = current_user.events.find_by(id: params[:id])
        return render_not_found unless event

        event.destroy
        head :no_content
      end

      private
        def event_params
          nested = params[:event]
          source = nested.is_a?(ActionController::Parameters) ? nested : params
          source.permit(:title, :body, :all_day, :starts_on, :ends_on, :starts_at, :ends_at)
        end

        def date_range_params
          from = params[:from].present? ? Date.iso8601(params[:from].to_s) : Date.current.beginning_of_month
          to = params[:to].present? ? Date.iso8601(params[:to].to_s) : Date.current.end_of_month
          to = from + Event::RANGE_MAX if (to - from).to_i > Event::RANGE_MAX
          [ from, to ]
        end
    end
  end
end
