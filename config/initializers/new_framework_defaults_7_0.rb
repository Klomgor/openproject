# Be sure to restart your server when you modify this file.
#
# This file eases your Rails 7.0 framework defaults upgrade.
#
# Uncomment each configuration one by one to switch to the new default.
# Once your application is ready to run with all new defaults, you can remove
# this file and set the `config.load_defaults` to `7.0`.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

# https://guides.rubyonrails.org/configuring.html#config-action-view-button-to-generates-button-tag
# `button_to` view helper will render `<button>` element, regardless of whether
# or not the content is passed as the first argument or as a block.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.action_view.button_to_generates_button_tag = true

# https://guides.rubyonrails.org/configuring.html#config-action-view-apply-stylesheet-media-default
# `stylesheet_link_tag` view helper will not render the media attribute by default.
# Previous versions had true. Rails 7.0+ default is false.
# Rails.application.config.action_view.apply_stylesheet_media_default = false

# https://guides.rubyonrails.org/configuring.html#config-active-support-key-generator-hash-digest-class
# Change the digest class for the key generators to `OpenSSL::Digest::SHA256`.
# Changing this default means invalidate all encrypted messages generated by
# your application and, all the encrypted cookies. Only change this after you
# rotated all the messages using the key rotator.
#
# See upgrading guide for more information on how to build a rotator.
# https://guides.rubyonrails.org/v7.0/upgrading_ruby_on_rails.html
# Previous versions had OpenSSL::Digest::SHA1.
# Rails 7.0+ default is OpenSSL::Digest::SHA256.
# Rails.application.config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA256

# https://guides.rubyonrails.org/configuring.html#config-active-support-hash-digest-class
# Change the digest class for ActiveSupport::Digest.
# Changing this default means that for example Etags change and
# various cache keys leading to cache invalidation.
# Rails 5.1 and before used OpenSSL::Digest::MD5.
# Rails 5.2 to 6.1 default is OpenSSL::Digest::SHA1.
# Rails 7.0+ default is OpenSSL::Digest::SHA256.
# Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA256

# https://guides.rubyonrails.org/configuring.html#config-active-support-remove-deprecated-time-with-zone-name
# Don't override ActiveSupport::TimeWithZone.name and use the default Ruby
# implementation.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_support.remove_deprecated_time_with_zone_name = true

# https://guides.rubyonrails.org/configuring.html#config-active-support-executor-around-test-case
# Calls `Rails.application.executor.wrap` around test cases.
# This makes test cases behave closer to an actual request or job.
# Several features that are normally disabled in test, such as Active Record query cache
# and asynchronous queries will then be enabled.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_support.executor_around_test_case = true

# https://guides.rubyonrails.org/configuring.html#config-active-support-isolation-level
# Define the isolation level of most of Rails internal state.
# If you use a fiber based server or job processor, you should set it to `:fiber`.
# Otherwise the default of `:thread` if preferable.
# Previous versions had :thread. Rails 7.0+ default is :fiber.
# Rails.application.config.active_support.isolation_level = :thread

# https://guides.rubyonrails.org/configuring.html#config-action-mailer-smtp-timeout
# Set both the `:open_timeout` and `:read_timeout` values for `:smtp` delivery method.
# Previous versions had nil. Rails 7.0+ default is 5.
# Rails.application.config.action_mailer.smtp_timeout = 5

# https://guides.rubyonrails.org/configuring.html#config-active-storage-video-preview-arguments
# The ActiveStorage video previewer will now use scene change detection to generate
# better preview images (rather than the previous default of using the first frame
# of the video).
# Previous versions used "-y -vframes 1 -f image2".
# Rails.application.config.active_storage.video_preview_arguments =
#   "-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"

# https://guides.rubyonrails.org/configuring.html#config-active-record-automatic-scope-inversing
# Automatically infer `inverse_of` for associations with a scope.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_record.automatic_scope_inversing = true

# https://guides.rubyonrails.org/configuring.html#config-active-record-verify-foreign-keys-for-fixtures
# Raise when running tests if fixtures contained foreign key violations
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_record.verify_foreign_keys_for_fixtures = true

# https://guides.rubyonrails.org/configuring.html#config-active-record-partial-inserts
# Disable partial inserts.
# This default means that all columns will be referenced in INSERT queries
# regardless of whether they have a default or not.
# Previous versions had true. Rails 7.0+ default is false.
Rails.application.config.active_record.partial_inserts = false

# https://guides.rubyonrails.org/configuring.html#config-action-controller-raise-on-open-redirects
# Protect from open redirect attacks in `redirect_back_or_to` and `redirect_to`.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.action_controller.raise_on_open_redirects = true

# https://guides.rubyonrails.org/configuring.html#config-active-storage-variant-processor
# Change the variant processor for Active Storage.
# Changing this default means updating all places in your code that
# generate variants to use image processing macros and ruby-vips
# operations. See the upgrading guide for detail on the changes required.
# The `:mini_magick` option is not deprecated; it's fine to keep using it.
# Previous versions had :mini_magick. Rails 7.0+ default is :vips.
# Rails.application.config.active_storage.variant_processor = :vips

# https://guides.rubyonrails.org/configuring.html#config-action-controller-wrap-parameters-by-default
# Enable parameter wrapping for JSON.
# Previously this was set in an initializer. It's fine to keep using that initializer if you've customized it.
# To disable parameter wrapping entirely, set this config to `false`.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.action_controller.wrap_parameters_by_default = true

# https://guides.rubyonrails.org/configuring.html#config-active-support-use-rfc4122-namespaced-uuids
# Specifies whether generated namespaced UUIDs follow the RFC 4122 standard for namespace IDs provided as a
# `String` to `Digest::UUID.uuid_v3` or `Digest::UUID.uuid_v5` method calls.
#
# See https://guides.rubyonrails.org/configuring.html#config-active-support-use-rfc4122-namespaced-uuids for
# more information.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_support.use_rfc4122_namespaced_uuids = true

# https://guides.rubyonrails.org/configuring.html#config-action-dispatch-default-headers
# Change the default headers to disable browsers' flawed legacy XSS protection.
# Rails.application.config.action_dispatch.default_headers = {
#   "X-Frame-Options" => "SAMEORIGIN",
#   "X-XSS-Protection" => "0",
#   "X-Content-Type-Options" => "nosniff",
#   "X-Download-Options" => "noopen",
#   "X-Permitted-Cross-Domain-Policies" => "none",
#   "Referrer-Policy" => "strict-origin-when-cross-origin"
# }

# https://guides.rubyonrails.org/configuring.html#config-active-support-cache-format-version
# ** Please read carefully, this must be configured in config/application.rb **
# Change the format of the cache entry.
# Changing this default means that all new cache entries added to the cache
# will have a different format that is not supported by Rails 6.1 applications.
# Only change this value after your application is fully deployed to Rails 7.0
# and you have no plans to rollback.
# When you're ready to change format, add this to `config/application.rb` (NOT this file):
#  config.active_support.cache_format_version = 7.0

# https://guides.rubyonrails.org/configuring.html#config-action-dispatch-cookies-serializer
# Cookie serializer: 2 options
#
# If you're upgrading and haven't set `cookies_serializer` previously, your cookie serializer
# is `:marshal`. The default for new apps is `:json`.
#
# Rails.application.config.action_dispatch.cookies_serializer = :json
#
#
# To migrate an existing application to the `:json` serializer, use the `:hybrid` option.
#
# Rails transparently deserializes existing (Marshal-serialized) cookies on read and
# re-writes them in the JSON format.
#
# It is fine to use `:hybrid` long term; you should do that until you're confident *all* your cookies
# have been converted to JSON. To keep using `:hybrid` long term, move this config to its own
# initializer or to `config/application.rb`.
#
# Rails.application.config.action_dispatch.cookies_serializer = :hybrid
#
#
# If your cookies can't yet be serialized to JSON, keep using `:marshal` for backward-compatibility.
#
# If you have configured the serializer elsewhere, you can remove this section of the file.
#
# See https://guides.rubyonrails.org/action_controller_overview.html#cookies for more information.

# https://guides.rubyonrails.org/configuring.html#config-action-dispatch-return-only-request-media-type-on-content-type
# Change the return value of `ActionDispatch::Request#content_type` to the Content-Type header without modification.
# Previous versions had true. Rails 7.0+ default is false.
# Rails.application.config.action_dispatch.return_only_request_media_type_on_content_type = false

# https://guides.rubyonrails.org/configuring.html#config-active-storage-multiple-file-field-include-hidden
# Active Storage `has_many_attached` relationships will default to replacing the current
# collection instead of appending to it. Thus, to support submitting an empty collection,
# the `file_field` helper will render an hidden field `include_hidden` by default when
# `multiple_file_field_include_hidden` is set to `true`.
# See https://guides.rubyonrails.org/configuring.html#config-active-storage-multiple-file-field-include-hidden
# for more information.
# Previous versions had false. Rails 7.0+ default is true.
# Rails.application.config.active_storage.multiple_file_field_include_hidden = true

# https://guides.rubyonrails.org/configuring.html#config-active-support-disable-to-s-conversion
# ** Please read carefully, this must be configured in config/application.rb (NOT this file) **
# Disables the deprecated #to_s override in some Ruby core classes
# See https://guides.rubyonrails.org/configuring.html#config-active-support-disable-to-s-conversion for more information.
# config.active_support.disable_to_s_conversion = true
