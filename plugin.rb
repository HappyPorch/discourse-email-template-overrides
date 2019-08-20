# name: discourse-email-template-overrides
# about: Plugin that overrides the default notifications email templates and styles in Discourse. 
# version: 0.1.1
# authors: HappyPorch
# url: https://github.com/HappyPorch/discourse-email-template-overrides/

after_initialize do
    # override notifications email code to use template override from plugin folder
    module UserNotificationsExtension
        protected def send_notification_email(opts)
            Rails.configuration.paths["app/views"].unshift(File.expand_path("../../../public/uploads/default/original/1X/email_template_overrides", __FILE__))
            super(opts)
        end
    end

    require_dependency 'user_notifications'
    class ::UserNotifications
        prepend UserNotificationsExtension
    end
    
    # add custom email styling
    email_style_overrides_path = File.expand_path("../../../public/uploads/default/original/1X/email_template_overrides/email_style_overrides.yml", __FILE__)
    
    if (File.file?(email_style_overrides_path))
        email_style_overrides = YAML.load_file(email_style_overrides_path)
        
        require_dependency 'email/styles'
        Email::Styles.register_plugin_style do |doc|
            if (email_style_overrides)
                email_style_overrides['email_style_overrides'].each do |style_selector, style|
                    doc.css(style_selector).each do |element|
                        element['style'] = style
                    end
                end
            end
        end
    end
end
