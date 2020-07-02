class AccountStatusHelper

    def self.account_status(userType, user, status, id)
        if status.nil? || status.empty?
           return {message: "account_status is empty", status: 400}
        end

        unless status == AccountStatus::APPROVED || status == AccountStatus::ACTIVE || status == AccountStatus::INCOMPLETE || status == AccountStatus::INACTIVE || status == AccountStatus::SUSPENDED || status == AccountStatus::CLOSED
          return {message: "Invalid status", status: 400}
        end

        if status == user.account_status
            return {message: "#{userType} id: #{id} status was not updated as the user is already #{status}", status: 204}
        end
        old_status = user.account_status
        success = user.update_attribute(:account_status, status)
        return success ?
            {message: "#{userType} id: #{id} status changed to #{status}. Was: #{old_status}", status: 200} :
            {message: "#{userType} id: #{id} status not changed to #{status}.  Remained: #{old_status}", status: 500}
    end
end
