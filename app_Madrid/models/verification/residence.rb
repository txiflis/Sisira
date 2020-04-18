class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service, :redeemable_code

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, length: { is: 5 }

  validate :allowed_age
  validate :document_number_uniqueness
  validate :redeemable_code_is_redeemable

  def initialize(attrs = {})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    self.redeemable_code ||= self.user.try(:redeemable_code)
    clean_document_number
  end

  def save
    return false unless valid?

    self.document_number = @census_api_response.document_number

    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number:       document_number,
                document_type:         document_type,
                geozone:               geozone,
                date_of_birth:         date_of_birth.in_time_zone.to_datetime,
                gender:                gender,
                residence_verified_at: Time.current)

    if redeemable_code.present?
      RedeemableCode.redeem(redeemable_code, user)
    end
    true
  end

  def allowed_age
    return if errors[:date_of_birth].any? ||  Age.in_years(date_of_birth) >= User.minimum_required_age_for_verification
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age'))
  end

  def document_number_uniqueness
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.active.where(document_number: document_number).any?
  end

  def redeemable_code_is_redeemable
    return if redeemable_code.blank?
    unless RedeemableCode.redeemable?(redeemable_code)
      errors.add(:redeemable_code, I18n.t('verification.residence.new.error_can_not_redeem_code'))
    end
  end

  def store_failed_attempt
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      date_of_birth: date_of_birth,
      postal_code: postal_code,
      district_code: district_code
    )
  end

  def geozone
    Geozone.where(census_code: district_code).first if district_code.present?
  end

  def district_code
    @census_api_response.district_code
  end

  def gender
    @census_api_response.gender
  end

  private

    def retrieve_census_data
      @census_api_response = CensusCaller.new.call(document_type, document_number)
    end

    def residency_valid?
      @census_api_response.valid? &&
        @census_api_response.postal_code == postal_code &&
        @census_api_response.date_of_birth == date_of_birth
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

end
