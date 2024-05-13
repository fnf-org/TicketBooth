# frozen_string_literal: true

Rails.application.config.active_record.encryption.primary_key         = TicketBooth::Application.setting(:active_record_encryption).primary_key
Rails.application.config.active_record.encryption.deterministic_key   = TicketBooth::Application.setting(:active_record_encryption).deterministic_key
Rails.application.config.active_record.encryption.key_derivation_salt = TicketBooth::Application.setting(:active_record_encryption).key_derivation_salt
