class Organization < ApplicationRecord
  default_scope { order('id DESC') }

  has_many :locations, dependent: :destroy, autosave: true
  has_many :programs, dependent: :destroy
  has_many :contacts, dependent: :destroy

  has_many :phones, dependent: :destroy, inverse_of: :organization
  accepts_nested_attributes_for :phones,
                                allow_destroy: true, reject_if: :all_blank

  validates :name,
            presence: { message: I18n.t('errors.messages.blank_for_org') },
            uniqueness: { case_sensitive: false }

  validates :description,
            presence: { message: I18n.t('errors.messages.blank_for_org') }

  validates :email, email: true, allow_blank: true
  validates :website, url: true, allow_blank: true
  validates :date_incorporated, date: true

  validates :accreditations, :funding_sources, :licenses, pg_array: true

  auto_strip_attributes :alternate_name, :description, :email, :legal_status,
                        :name, :tax_id, :tax_status, :website

  def self.with_locations(ids)
    joins(:locations).where(locations: { id: ids }).distinct
  end

  extend FriendlyId
  friendly_id :name, use: [:history]

  after_save :touch_locations, if: :needs_touch?

  private

  def needs_touch?
    return false if locations.count.zero?

    saved_change_to_name?
  end

  def touch_locations
    locations.find_each(&:touch)
  end
end
