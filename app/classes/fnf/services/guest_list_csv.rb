# frozen_string_literal: true

require 'csv'

module FnF
  module Services
    class GuestListCSV
      attr_accessor :event, :guests

      HEADER = [
        'Ticket Request ID',
        'Ticket Request Status',
        'Ticket Requester Name',
        'Guest/Kids Name',
        'Guests Email/Kids Age',
        'Role',
        'Event Passes',
        'Camping Permits'
      ].freeze

      GuestRow = Struct.new(:ticket_request_id,
                            :status,
                            :tr_name,
                            :guest_name,
                            :guest_email,
                            :role,
                            :event_passes,
                            :camping_permits)

      def initialize(event)
        self.event  = event
        self.guests = build_list
      end

      # @return path <String> location of the temporary file with the CSV
      def csv
        ::CSV.open(temp_csv_file.path, 'w',
                   write_headers: true,
                   headers:       HEADER) do |csv|
          guests.each do |row|
            csv << row
          end
        end
        temp_csv_file.path
      end

      private

      def build_list
        [].tap do |guest_list|
          event.admissible_requests.each do |tr|
            requester = [tr.status_name, tr.user.name]

            passes = tr.active_sorted_addons_by_category(Addon::CATEGORY_PASS).map { |a| "#{a.name}: #{a.quantity}" }
            permits = tr.active_sorted_addons_by_category(Addon::CATEGORY_CAMP).map { |a| "#{a.name}: #{a.quantity}" }

            tr.guests.each do |guest|
              guest_name, guest_email = case guest
                                        when /, \d+$/
                                          guest.split(/,\s+/)
                                        when /\s\d+$/
                                          [guest.gsub(/\s\d+$/, ''), guest.gsub(/\D/, '')]
                                        when /[<>]/
                                          guest.split(/[<>]/)
                                        when /[(@)]/
                                          guest.split(/[()]/)
                                        else
                                          [guest, '']
                                        end
              row = GuestRow.new(tr.id,
                                 *requester,
                                 guest_name,
                                 guest_email,
                                 tr.role,
                                 passes.to_sentence,
                                 permits.to_sentence)

              guest_list << row.to_a
            end
          end
        end
      end

      def temp_csv_file
        @temp_csv_file ||= Tempfile.new('csv')
      end
    end
  end
end
