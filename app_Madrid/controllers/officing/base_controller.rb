class Officing::BaseController < ApplicationController
  layout 'admin'
  helper_method :current_booth

  before_action :authenticate_user!
  before_action :verify_officer

  skip_authorization_check

  private

    def verify_officer
      raise CanCan::AccessDenied unless current_user.try(:poll_officer?)
    end

    def load_officer_assignment
      @officer_assignments ||= current_user.poll_officer.officer_assignments.where(date: Time.current.to_date)
    end

    def verify_officer_assignment
      if @officer_assignments.blank?
        redirect_to officing_root_path, notice: t("officing.residence.flash.not_allowed")
      end
    end

    def verify_booth
      return unless current_booth.blank?
      booths = todays_booths_for_officer(current_user.poll_officer)
      case booths.count
      when 0
        redirect_to officing_root_path
      when 1
        session[:booth_id] = booths.first.id
      else
        redirect_to new_officing_booth_path
      end
    end

    def current_booth
      Poll::Booth.where(id: session[:booth_id]).first
    end

    def todays_booths_for_officer(officer)
      officer.officer_assignments.by_date(Date.today).map(&:booth).uniq
    end

    def letter?
      false
    end

end
