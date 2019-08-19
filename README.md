# discourse-email-template-overrides

Plugin that overrides the default notifications email templates in Discourse.

## How To Use

When this plugin is installed the email notifications can be customised in two ways:

-   The markup of the post information contained in the notification email sent out.
-   The styling of the notification email sent out.

### Custom Markup

The pluging will look for the `_post.html.erb` file in the upload directory of your Discourse instance, where a custom folder should be added: `/var/www/discourse/public/uploads/default/original/1X/email_template_overrides/email/` (the `email` folder matches the same structure as the default template used in Discourse).
If the file cannot be found it will use the default template file instead.

You template file can contain custom code/markup to customise the post information included in each notification email:

```
<%
  require_dependency 'guardian'

  guardian = Guardian.new(post.user)

  if (added_fields = User.whitelisted_user_custom_fields(guardian)).present?
    user_custom_fields = User.custom_fields_for_ids([post.user.id], added_fields)[post.user.id] || {}

    if (user_custom_fields.present?)
      display_custom_fields = Array.new

      if (user_custom_fields['user_field_2'].present?)
          display_custom_fields.push(user_custom_fields['user_field_2'])
      end

      if (user_custom_fields['user_field_6'].present?)
          if (display_custom_fields.length > 0)
              display_custom_fields.push(', ')
          end

          display_custom_fields.push(user_custom_fields['user_field_6'])
      end

      if (display_custom_fields.length > 0)
          display_custom_fields.insert(0, ' | ')
      end

    end
  end
%>

<div class='post-wrapper <%= post.whisper? ? "whisper" : "" %> <%= use_excerpt ? "excerpt" : ""%>'>
  <table>
    <tr>
      <td class='user-avatar'>
        <img src="<%= post.user.small_avatar_url %>" title="<%= post.user.username%>">
      </td>
      <td>
        <%- if show_username_on_post(post) %>
        <a class="username" href="<%=Discourse.base_url%>/u/<%= post.user.username_lower%>" target="_blank"><%= post.user.username %></a>
        <% end %>
        <%- if show_name_on_post(post) %>
          <a class="username" href="<%=Discourse.base_url%>/u/<%= post.user.username_lower%>" target="_blank"><%= post.user.name %></a>
        <% end %>
        <%- if post.user.title.present? %>
          <span class='user-title'><%= post.user.title %></span>
        <% end %>
        <%- if display_custom_fields.present? %>
          <span class='user-title'>
          <%= display_custom_fields.join('').html_safe %>
          </span>
        <% end %>
        <br>
        <span class='notification-date'><%= l post.created_at, format: :short_no_year %></span>
      </td>
    </tr>
  </table>
  <div class='body'><%= format_for_email(post, use_excerpt) %></div>
</div>
```

(the example above includes some of the user's custom fields in the notification email)

### Email Style Overrides

To add or override any of the notification email styles (which get included in the `style` attributes in the generated email) you can include a YAML file in the same upload directory of your Discourse instance: `/var/www/discourse/public/uploads/default/original/1X/email_template_overrides/email_style_overrides.yml`.

The YAML file should have the following format:

```
email_style_overrides:
    '.user-title a': 'color: #999; font-weight: normal; text-decoration: none;'
    '.notification-date': 'color: #666;'
```

The key of each YAML line is the CSS selector of the element(s) you wish to target.
The value of each item contains the styles you wish to add to that element.

## How To Install
Follow the [default plugin installation guide](https://meta.discourse.org/t/install-plugins-in-discourse/19157) as provided by Discourse.
