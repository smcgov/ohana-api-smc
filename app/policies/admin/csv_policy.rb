class Admin
  class CsvPolicy
    SPECIAL_GUESTS = ENV['CSV_ACCESS_LIST'].freeze

    def initialize(admin:)
      @admin = admin
    end

    def authorized_to_download_csv_files?
      return false unless admin

      admin.super_admin? || special_guest?
    end

    private

    attr_reader :admin

    def special_guest?
      return false if SPECIAL_GUESTS.blank?

      SPECIAL_GUESTS.split(',').include?(admin.email)
    end
  end
end
