# Ticket Booth — Bugs & Remaining Work

Verified on 2026-03-22. All bugs below have been confirmed to still exist in the codebase.

---

## Bugs — Sorted by Severity

### Critical

#### BUG-001: XSS Vulnerability in Email Template
- **File:** `app/mailers/ticket_request_mailer.rb:138`
- **Issue:** `@body = body.to_s.html_safe` marks user-supplied input as safe HTML without sanitization. Event admins can inject arbitrary HTML/JavaScript into emails sent to all ticket holders.
- **Impact:** Malicious scripts execute in recipients' email clients. Combined with the Trix rich text editor (which outputs HTML), this is especially dangerous.
- **Fix:** Replace `.html_safe` with `sanitize(body.to_s)` using a Rails sanitization allowlist, or use `ActionView::Helpers::SanitizeHelper`.

#### BUG-004: Missing Subject in `email_ticket_holder` Mailer
- **File:** `app/mailers/ticket_request_mailer.rb:157`
- **Verified:** Line 157 reads `subject:` with no value — the keyword argument is empty.
- **Impact:** Emails sent to all ticket holders have blank subjects, likely causing delivery failures or spam filtering.
- **Fix:** Change to `subject: @subject` and ensure the controller passes the subject param through.

### High

#### BUG-005: Race Condition in Payment Refund Flow
- **File:** `app/models/ticket_request.rb:258-275`, `app/models/payment.rb:159-183`
- **Verified:** `refund` method checks `refunded?` then calls `payment.refund_stripe_payment` without any locking. `refund_stripe_payment` similarly checks `received?` then calls `Stripe::Refund.create` without locking.
- **Impact:** Two concurrent refund requests could both pass the guard check and submit two Stripe refunds for the same payment.
- **Fix:** Wrap the refund flow in `with_lock` or `SELECT ... FOR UPDATE`.

#### BUG-006: No Idempotency Key on Stripe PaymentIntent Creation
- **File:** `app/models/payment.rb:108-120`
- **Verified:** `Stripe::PaymentIntent.create` is called without an `idempotency_key`. If `save` fails after the API call succeeds, retrying creates a duplicate PaymentIntent.
- **Impact:** Potential double-charges to customers.
- **Fix:** Generate and store a `SecureRandom.uuid` on the payment record before calling Stripe, pass as `idempotency_key`.

#### BUG-008: Stale Price Cache from Instance Variable Memoization
- **File:** `app/models/ticket_request.rb:278-300`
- **Verified:** `@price`, `@calculate_addons_price`, `@active_addons`, `@active_addon_pass_sum` all use `||=` memoization. No cache invalidation when attributes change within the same request.
- **Impact:** If addons or quantities are modified, stale cached prices are used for payment calculations — customers could be over- or under-charged.
- **Fix:** Remove `||=` memoization, or add `after_save` / attribute change callbacks to clear instance variables.

### Medium

#### BUG-009: Mass Assignment in SiteAdminsController
- **File:** `app/controllers/site_admins_controller.rb:16`
- **Verified:** `SiteAdmin.new(params[:site_admin])` — passes raw params without `permit`. Relies on `attr_accessible` from the deprecated `protected_attributes_continued` gem.
- **Impact:** When `protected_attributes_continued` is eventually removed (it's a legacy compatibility gem), this becomes a mass assignment vulnerability allowing privilege escalation.
- **Fix:** Add `params.require(:site_admin).permit(:user_id)`.

#### BUG-010: Logic Error in `User.canonize_full_name!`
- **File:** `app/models/user.rb:130-137`
- **Verified:** Line 135 checks `if name && last` but line 133 confirmed `name.nil?`. The condition `name && last` is always false, so last name is never appended.
- **Impact:** Users who sign up with first/last names but no full name get only their first name stored in `name`.
- **Fix:** Change line 135 to `self.name += " #{last}" if last.present?`.

#### BUG-011: Email Delivery Inside Database Transaction
- **File:** `app/models/payment.rb:227-234`
- **Verified:** `PaymentMailer.payment_received(self).deliver_later` is called inside `Payment.transaction do ... end`.
- **Impact:** If the transaction rolls back after the job is enqueued, the email job may still execute — sending a "payment received" email for a payment that wasn't actually recorded.
- **Fix:** Move the email delivery to an `after_commit` callback or call it after the transaction block.

### Low

#### BUG-012: Deprecated `update_attribute` Calls
- **Files:** `app/models/user.rb:126`, `app/controllers/ticket_requests_controller.rb:237`
- **Verified:** Both still use `update_attribute` which skips validations.
- **Fix:** Use `update_column` (skip callbacks too) or `update!` (with validations).

#### BUG-013: Deprecated `redirect_to :back`
- **File:** `app/controllers/events_controller.rb:78, 98, 102`
- **Verified:** Three occurrences of `redirect_to :back` — deprecated since Rails 5.
- **Impact:** Raises `ActionController::RedirectBackError` if there's no HTTP referer.
- **Fix:** Use `redirect_back(fallback_location: root_path)`.

#### BUG-014: Duplicate Authorization Methods
- **File:** `app/models/ticket_request.rb:189-195`
- **Verified:** `can_view?` and `owner?` have identical implementations: `self.user == user || event.admin?(user)`.
- **Fix:** Remove one and alias the other, or differentiate their semantics.

#### BUG-015: `$emailField` Typo in tickets_request_controller.js
- **File:** `app/javascript/controllers/tickets_request_controller.js:21`
- **Verified:** `$emailField` is referenced but never defined; should be `emailField` (the local variable on line 19).
- **Impact:** Email duplicate-account lookup is completely broken — the feature silently fails.
- **Fix:** Change `$emailField` to `emailField`.

---

## Completed in This PR

### Bugs Fixed
- ~~BUG-016: Test factory password~~ — Factory updated to meet password complexity requirements (was causing 167 test failures)
- ~~BUG-002/003/007: Authorization on download/email/payment_reminder~~ — Verified SAFE via test. Authorization was correctly enforced; original report was incorrect. Tests added to prove it.

### Asset Pipeline
- Removed webpack-era dead code (css-loader, mini-css-extract-plugin, sass-loader, fs, babel config)
- Consolidated esbuild to single entry point
- Updated `config.load_defaults` 7.1 → 8.1
- Removed Sprockets-era settings from production.rb and assets.rb
- Silenced Sass deprecation warnings (`--quiet-deps --silence-deprecation=import`)
- Added Trix rich text editor
- jQuery removed from flash_controller.js

### Features
- Secret token on events for unguessable ticket request URLs
- i18n locale file for password/auth strings
- Solid Cache configured correctly

### Testing
- 587 examples, 0 failures, 71.48% line coverage (up from 336 examples / 167 failures / 42.5%)

---

## Remaining Work (Future PRs)

### jQuery Removal
- `tickets_request_controller.js` — 31 jQuery calls need converting to vanilla JS
- Last dependency blocking removal of jQuery package (~241KB bundle savings)

### UI Pages Not Yet Modernized
- Guest list page (`app/views/events/guest_list.html.haml`)
- Event edit form (`app/views/events/_form.html.haml`)
- Site admins page (`app/views/site_admins/index.html.haml`)
- Devise confirmation/unlock pages
- Email templates (`app/views/layouts/email.html.haml`, `app/views/ticket_request_mailer/`)

### Infrastructure
- Vanta.js loaded from CDN — consider bundling locally or lazy-loading
- CSS responsive breakpoints don't align with Bootstrap's standard breakpoints
- Test coverage target: 90% (currently 71.48%)
