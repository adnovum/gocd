#
# Copyright 2019 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Api
  module WebHooks
    class HostedBitBucketController < WebHookController
      before_action :prempt_ping_call
      before_action :verify_content_origin
      before_action :allow_only_push_event
      before_action :allow_only_git_scm
      before_action :verify_payload

      protected

      def possible_urls
        payload_repo['links']['clone'].collect {|l| without_credentials(l['href'])}
      end

      def without_credentials (str)
        uri = URI.parse(str)
        uri.user = nil
        uri.password = nil
        uri.to_s()
      rescue
        str
      end

      def repo_branch
        payload['changes'].find {|change| change['ref']['type'] == 'BRANCH'}['ref']['displayId']
      rescue
        nil
      end

      def repo_log_name
        hostname = URI.parse(possible_urls[0]).hostname
        reponame = payload_repo['name']
        "#{hostname}/#{reponame}"
      end

      def prempt_ping_call
        if request.headers['X-Event-Key'] == 'diagnostics:ping'
          render plain: nil, status: :accepted, layout: nil
        end
      end

      def allow_only_push_event
        # FIXME: check if pr:modified is really right
        unless is_git_event or is_pr_event
          render plain: "Ignoring event of type `#{request.headers['X-Event-Key']}'", status: :bad_request, layout: nil
        end
      end

      def is_git_event
        request.headers['X-Event-Key'] == 'repo:refs_changed'
      end

      def is_pr_event
        ['pr:opened', 'pr:modified'].include?(request.headers['X-Event-Key'])
      end

      def verify_payload
        if payload.blank?
          render plain: 'Could not understand the payload!', status: :bad_request, layout: nil
        end
        if !is_pr_event && repo_branch.blank?
          render plain: 'No branch present in payload, ignoring.', status: :bad_request, layout: nil
        end
      rescue => e
        Rails.logger.warn('Could not understand bitbucket webhook payload:')
        Rails.logger.warn(e)
        render plain: 'Could not understand the payload!', status: :bad_request, layout: nil
      end

      def payload
        if request.content_mime_type == :json
          JSON.parse(request.raw_post)
        end
      end

      def verify_content_origin
        if request.headers['X-Hub-Signature'].blank?
          return render plain: "No HMAC signature specified via `X-Hub-Signature' header!", status: :bad_request, layout: nil
        end

        expected_signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), webhook_secret, request.body.read)

        unless Rack::Utils.secure_compare(expected_signature, request.headers['X-Hub-Signature'])
          render plain: "HMAC signature specified via `X-Hub-Signature' did not match!", status: :bad_request, layout: nil
        end
      end

      def allow_only_git_scm
      	if is_pr_event
      	  if payload['pullRequest']['toRef']['repository']['scmId'] != 'git'
            render plain: "Only `git' repositories are currently supported!", status: :bad_request, layout: nil
          end
      	else
		  if payload_repo['scmId'] != 'git'
		    render plain: "Only `git' repositories are currently supported!", status: :bad_request, layout: nil
		  end
		end
      end

      def payload_repo
        if is_pr_event
          payload['pullRequest']['toRef']['repository']
        else
          payload['repository']
        end
      end
    end

  end
end