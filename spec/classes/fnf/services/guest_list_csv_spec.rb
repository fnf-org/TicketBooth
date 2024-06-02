# frozen_string_literal: true

require 'rspec'

RSpec.describe 'FnF::Services::GuestListCSV' do
  subject(:service) { FnF::Services::GuestListCSV.new(event) }

  let(:event) { create(:event) }
  let(:number_of_ticket_requests) { 5 }
  let(:ticket_requests) do
    create_list(:ticket_request,
                number_of_ticket_requests,
                :includes_user_and_kids,
                :completed,
                event:)
  end

  before { ticket_requests }

  it 'has 5 ticket requests' do
    expect(event.ticket_requests.size).to eq number_of_ticket_requests
  end

  it 'has 15 guests' do
    expect(event.ticket_requests.map(&:guests).flatten.size).to eq number_of_ticket_requests * 3
  end

  describe 'ticket_request guests' do
    let(:user) { ticket_requests.first&.user }
    let(:first_guest) { ticket_requests.first&.guests&.first }

    it 'has 3 guests' do
      ticket_requests.each do |tr|
        expect(tr.guests.size).to eq 3
      end
    end

    it 'has the user as the first guest' do
      expect(first_guest).to eq "#{user.name} <#{user.email}>"
    end
  end

  describe '#guests' do
    subject { service.guests }

    it { is_expected.to be_a(Array) }
    its(:size) { is_expected.to eq(number_of_ticket_requests * 3) }
  end

  describe '#csv' do
    subject(:csv) { service.csv }

    let(:csv_contents) { File.read(csv) }

    it 'produces an existing temp file' do
      expect(File).to exist(csv)
    end

    describe 'each line of the CSV file' do
      subject(:lines) { csv_contents.split("\n") }

      its(:first) { is_expected.to eq(FnF::Services::GuestListCSV::HEADER.join(',')) }
      its(:size) { is_expected.to eq((number_of_ticket_requests * 3) + 1) }
    end
  end
end
