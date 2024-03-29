<?php
// $Id: user-profile.tpl.php,v 1.11 2009/08/22 00:58:55 webchick Exp $

/**
 * @file
 * Default theme implementation to present all user profile data.
 *
 * This template is used when viewing a registered member's profile page,
 * e.g., example.com/user/123. 123 being the users ID.
 *
 * Use render($user_profile) to print all profile items, or print a subset
 * such as render($content['field_example']). Always call render($user_profile)
 * at the end in order to print all remaining items. If the item is a category,
 * it will contain all its profile items. By default, $user_profile['summary']
 * is provided which contains data on the user's history. Other data can be
 * included by modules. $user_profile['user_picture'] is available
 * for showing the account picture.
 *
 * Field variables: for each field instance attached to the user a corresponding
 * variable is defined, e.g. $user->field_example becomes $field_example. When
 * needing to access a field's raw values, developers/themers are strongly
 * encouraged to use these variables. Otherwise they will have to explicitly
 * specify the desired field language, e.g. $user->field_example['en'], thus
 * overriding any language negotiation rule that was previously applied.
 *
 * @see user-profile-category.tpl.php
 *   Where the html is handled for the group.
 * @see user-profile-field.tpl.php
 *   Where the html is handled for each item in the group.
 *
 * Available variables:
 *   - $user_profile: An array of profile items. Use render() to print them.
 *
 * @see template_preprocess_user_profile()
 */
?>
<div class="profile">
  <?php print render($user_profile); ?>
</div>
