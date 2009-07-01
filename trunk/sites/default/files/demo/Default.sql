-- Demo.module database dump (version 1.1)
-- http://drupal.org/project/demo
--
-- Database: d7ux
-- Date: Tuesday, June 30, 2009 - 16:04

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS = 0;

--
-- Table structure for table 'actions'
--

CREATE TABLE IF NOT EXISTS `actions` (
  `aid` varchar(255) NOT NULL default '0' COMMENT 'Primary Key: Unique actions ID.',
  `type` varchar(32) NOT NULL default '' COMMENT 'The object that that action acts on (node, user, comment, system or custom types.)',
  `callback` varchar(255) NOT NULL default '' COMMENT 'The callback function that executes when the action runs.',
  `parameters` longtext NOT NULL COMMENT 'Parameters to be passed to the callback function.',
  `description` varchar(255) NOT NULL default '0' COMMENT 'Description of the action.',
  PRIMARY KEY  (`aid`)
);

--
-- Dumping data for table 'actions'
--

/*!40000 ALTER TABLE actions DISABLE KEYS */;
INSERT INTO `actions` VALUES
('comment_unpublish_action', 'comment', 'comment_unpublish_action', '', 'Unpublish comment'),
('node_publish_action', 'node', 'node_publish_action', '', 'Publish post'),
('node_unpublish_action', 'node', 'node_unpublish_action', '', 'Unpublish post'),
('node_make_sticky_action', 'node', 'node_make_sticky_action', '', 'Make post sticky'),
('node_make_unsticky_action', 'node', 'node_make_unsticky_action', '', 'Make post unsticky'),
('node_promote_action', 'node', 'node_promote_action', '', 'Promote post to front page'),
('node_unpromote_action', 'node', 'node_unpromote_action', '', 'Remove post from front page'),
('node_save_action', 'node', 'node_save_action', '', 'Save post'),
('system_block_ip_action', 'user', 'system_block_ip_action', '', 'Ban IP address of current user'),
('user_block_user_action', 'user', 'user_block_user_action', '', 'Block current user');
/*!40000 ALTER TABLE actions ENABLE KEYS */;

--
-- Table structure for table 'actions_aid'
--

CREATE TABLE IF NOT EXISTS `actions_aid` (
  `aid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique actions ID.',
  PRIMARY KEY  (`aid`)
);

--
-- Dumping data for table 'actions_aid'
--

/*!40000 ALTER TABLE actions_aid DISABLE KEYS */;
/*!40000 ALTER TABLE actions_aid ENABLE KEYS */;

--
-- Table structure for table 'authmap'
--

CREATE TABLE IF NOT EXISTS `authmap` (
  `aid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique authmap ID.',
  `uid` int(11) NOT NULL default '0' COMMENT 'User’s users.uid.',
  `authname` varchar(128) NOT NULL default '' COMMENT 'Unique authentication name.',
  `module` varchar(128) NOT NULL default '' COMMENT 'Module which is controlling the authentication.',
  PRIMARY KEY  (`aid`),
  UNIQUE KEY `authname` (`authname`)
);

--
-- Dumping data for table 'authmap'
--

/*!40000 ALTER TABLE authmap DISABLE KEYS */;
/*!40000 ALTER TABLE authmap ENABLE KEYS */;

--
-- Table structure for table 'batch'
--

CREATE TABLE IF NOT EXISTS `batch` (
  `bid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique batch ID.',
  `token` varchar(64) NOT NULL COMMENT 'A string token generated against the current user’s session id and the batch id, used to ensure that only the user who submitted the batch can effectively access it.',
  `timestamp` int(11) NOT NULL COMMENT 'A Unix timestamp indicating when this batch was submitted for processing. Stale batches are purged at cron time.',
  `batch` longtext COMMENT 'A serialized array containing the processing data for the batch.',
  PRIMARY KEY  (`bid`),
  KEY `token` (`token`)
);

--
-- Dumping data for table 'batch'
--

/*!40000 ALTER TABLE batch DISABLE KEYS */;
/*!40000 ALTER TABLE batch ENABLE KEYS */;

--
-- Table structure for table 'block'
--

CREATE TABLE IF NOT EXISTS `block` (
  `bid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique block ID.',
  `module` varchar(64) NOT NULL default '' COMMENT 'The module from which the block originates; for example, ’user’ for the Who’s Online block, and ’block’ for any custom blocks.',
  `delta` varchar(32) NOT NULL default '0' COMMENT 'Unique ID for block within a module.',
  `theme` varchar(64) NOT NULL default '' COMMENT 'The theme under which the block settings apply.',
  `status` tinyint(4) NOT NULL default '0' COMMENT 'Block enabled status. (1 = enabled, 0 = disabled)',
  `weight` tinyint(4) NOT NULL default '0' COMMENT 'Block weight within region.',
  `region` varchar(64) NOT NULL default '' COMMENT 'Theme region within which the block is set.',
  `custom` tinyint(4) NOT NULL default '0' COMMENT 'Flag to indicate how users may control visibility of the block. (0 = Users cannot control, 1 = On by default, but can be hidden, 2 = Hidden by default, but can be shown)',
  `visibility` tinyint(4) NOT NULL default '0' COMMENT 'Flag to indicate how to show blocks on pages. (0 = Show on all pages except listed pages, 1 = Show only on listed pages, 2 = Use custom PHP code to determine visibility)',
  `pages` text NOT NULL COMMENT 'Contents of the `Pages` block; contains either a list of paths on which to include/exclude the block or PHP code, depending on `visibility` setting.',
  `title` varchar(64) NOT NULL default '' COMMENT 'Custom title for the block. (Empty string will use block default title, <none> will remove the title, text will cause block to use specified title.)',
  `cache` tinyint(4) NOT NULL default '1' COMMENT 'Binary flag to indicate block cache mode. (-1: Do not cache, 1: Cache per role, 2: Cache per user, 4: Cache per page, 8: Block cache global) See BLOCK_CACHE_* constants in block.module for more detailed information.',
  PRIMARY KEY  (`bid`),
  UNIQUE KEY `tmd` (`theme`,`module`,`delta`),
  KEY `list` (`theme`,`status`,`region`,`weight`,`module`)
);

--
-- Dumping data for table 'block'
--

/*!40000 ALTER TABLE block DISABLE KEYS */;
INSERT INTO `block` VALUES
('1', 'system', 'main', 'garland', '1', '0', 'content', '0', '0', '', '', '-1'),
('2', 'user', 'login', 'garland', '1', '0', 'left', '0', '0', '', '', '-1'),
('3', 'system', 'navigation', 'garland', '1', '0', 'left', '0', '0', '', '', '-1'),
('4', 'system', 'management', 'garland', '1', '1', 'left', '0', '0', '', '', '-1'),
('5', 'system', 'powered-by', 'garland', '1', '10', 'footer', '0', '0', '', '', '-1'),
('6', 'system', 'help', 'garland', '1', '0', 'help', '0', '0', '', '', '-1'),
('7', 'comment', 'recent', 'garland', '0', '0', '', '0', '0', '', '', '1'),
('8', 'menu', 'admin', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('9', 'node', 'syndicate', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('10', 'system', 'user-menu', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('11', 'system', 'main-menu', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('12', 'system', 'secondary-menu', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('13', 'user', 'new', 'garland', '0', '0', '', '0', '0', '', '', '1'),
('14', 'user', 'online', 'garland', '0', '0', '', '0', '0', '', '', '-1'),
('15', 'comment', 'recent', 'overlay', '0', '0', 'left', '0', '0', '', '', '1'),
('16', 'menu', 'admin', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1'),
('17', 'node', 'syndicate', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1'),
('18', 'system', 'help', 'overlay', '1', '0', 'help', '0', '0', '', '', '-1'),
('19', 'system', 'main', 'overlay', '1', '0', 'content', '0', '0', '', '', '-1'),
('20', 'system', 'main-menu', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1'),
('21', 'system', 'management', 'overlay', '1', '1', 'left', '0', '0', '', '', '-1'),
('22', 'system', 'navigation', 'overlay', '1', '0', 'left', '0', '0', '', '', '-1'),
('23', 'system', 'powered-by', 'overlay', '1', '10', 'footer', '0', '0', '', '', '-1'),
('24', 'system', 'secondary-menu', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1'),
('25', 'system', 'user-menu', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1'),
('26', 'user', 'login', 'overlay', '1', '0', 'left', '0', '0', '', '', '-1'),
('27', 'user', 'new', 'overlay', '0', '0', 'left', '0', '0', '', '', '1'),
('28', 'user', 'online', 'overlay', '0', '0', 'left', '0', '0', '', '', '-1');
/*!40000 ALTER TABLE block ENABLE KEYS */;

--
-- Table structure for table 'block_role'
--

CREATE TABLE IF NOT EXISTS `block_role` (
  `module` varchar(64) NOT NULL COMMENT 'The block’s origin module, from block.module.',
  `delta` varchar(32) NOT NULL COMMENT 'The block’s unique delta within module, from block.delta.',
  `rid` int(10) unsigned NOT NULL COMMENT 'The user’s role ID from users_roles.rid.',
  PRIMARY KEY  (`module`,`delta`,`rid`),
  KEY `rid` (`rid`)
);

--
-- Dumping data for table 'block_role'
--

/*!40000 ALTER TABLE block_role DISABLE KEYS */;
/*!40000 ALTER TABLE block_role ENABLE KEYS */;

--
-- Table structure for table 'blocked_ips'
--

CREATE TABLE IF NOT EXISTS `blocked_ips` (
  `iid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: unique ID for IP addresses.',
  `ip` varchar(32) NOT NULL default '' COMMENT 'IP address',
  PRIMARY KEY  (`iid`),
  KEY `blocked_ip` (`ip`)
);

--
-- Dumping data for table 'blocked_ips'
--

/*!40000 ALTER TABLE blocked_ips DISABLE KEYS */;
/*!40000 ALTER TABLE blocked_ips ENABLE KEYS */;

--
-- Table structure for table 'box'
--

CREATE TABLE IF NOT EXISTS `box` (
  `bid` int(10) unsigned NOT NULL auto_increment COMMENT 'The block’s block.bid.',
  `body` longtext COMMENT 'Block contents.',
  `info` varchar(128) NOT NULL default '' COMMENT 'Block description.',
  `format` smallint(6) NOT NULL default '0' COMMENT 'Block body’s filter_format.format; for example, 1 = Filtered HTML.',
  PRIMARY KEY  (`bid`),
  UNIQUE KEY `info` (`info`)
);

--
-- Dumping data for table 'box'
--

/*!40000 ALTER TABLE box DISABLE KEYS */;
/*!40000 ALTER TABLE box ENABLE KEYS */;

--
-- Table structure for table 'cache'
--

CREATE TABLE IF NOT EXISTS `cache` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_block'
--

CREATE TABLE IF NOT EXISTS `cache_block` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_field'
--

CREATE TABLE IF NOT EXISTS `cache_field` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Dumping data for table 'cache_field'
--

/*!40000 ALTER TABLE cache_field DISABLE KEYS */;
INSERT INTO `cache_field` VALUES
('field_info_types', 'a:4:{s:11:"field types";a:10:{s:4:"list";a:6:{s:5:"label";s:4:"List";s:11:"description";s:186:"This field stores numeric keys from key/value lists of allowed values where the key is a simple alias for the position of the value, i.e. 0|First option, 1|Second option, 2|Third option.";s:8:"settings";a:1:{s:23:"allowed_values_function";s:0:"";}s:14:"default_widget";s:14:"options_select";s:17:"default_formatter";s:12:"list_default";s:6:"module";s:4:"list";}s:12:"list_boolean";a:6:{s:5:"label";s:7:"Boolean";s:11:"description";s:50:"This field stores simple on/off or yes/no options.";s:8:"settings";a:1:{s:23:"allowed_values_function";s:0:"";}s:14:"default_widget";s:14:"options_select";s:17:"default_formatter";s:12:"list_default";s:6:"module";s:4:"list";}s:11:"list_number";a:6:{s:5:"label";s:14:"List (numeric)";s:11:"description";s:187:"This field stores keys from key/value lists of allowed numbers where the stored numeric key has significance and must be preserved, i.e. ''Lifetime in days'': 1|1 day, 7|1 week, 31|1 month.";s:8:"settings";a:1:{s:23:"allowed_values_function";s:0:"";}s:14:"default_widget";s:14:"options_select";s:17:"default_formatter";s:12:"list_default";s:6:"module";s:4:"list";}s:9:"list_text";a:6:{s:5:"label";s:11:"List (text)";s:11:"description";s:173:"This field stores keys from key/value lists of allowed values where the stored key has significance and must be a varchar, i.e. ''US States'': IL|Illinois, IA|Iowa, IN|Indiana";s:8:"settings";a:1:{s:23:"allowed_values_function";s:0:"";}s:14:"default_widget";s:14:"options_select";s:17:"default_formatter";s:12:"list_default";s:6:"module";s:4:"list";}s:14:"number_integer";a:6:{s:5:"label";s:7:"Integer";s:11:"description";s:57:"This field stores a number in the database as an integer.";s:17:"instance_settings";a:4:{s:3:"min";s:0:"";s:3:"max";s:0:"";s:6:"prefix";s:0:"";s:6:"suffix";s:0:"";}s:14:"default_widget";s:6:"number";s:17:"default_formatter";s:14:"number_integer";s:6:"module";s:6:"number";}s:14:"number_decimal";a:7:{s:5:"label";s:7:"Decimal";s:11:"description";s:69:"This field stores a number in the database in a fixed decimal format.";s:8:"settings";a:3:{s:9:"precision";i:10;s:5:"scale";i:2;s:7:"decimal";s:2:" .";}s:17:"instance_settings";a:4:{s:3:"min";s:0:"";s:3:"max";s:0:"";s:6:"prefix";s:0:"";s:6:"suffix";s:0:"";}s:14:"default_widget";s:6:"number";s:17:"default_formatter";s:14:"number_integer";s:6:"module";s:6:"number";}s:12:"number_float";a:6:{s:5:"label";s:5:"Float";s:11:"description";s:70:"This field stores a number in the database in a floating point format.";s:17:"instance_settings";a:4:{s:3:"min";s:0:"";s:3:"max";s:0:"";s:6:"prefix";s:0:"";s:6:"suffix";s:0:"";}s:14:"default_widget";s:6:"number";s:17:"default_formatter";s:14:"number_integer";s:6:"module";s:6:"number";}s:4:"text";a:7:{s:5:"label";s:4:"Text";s:11:"description";s:47:"This field stores varchar text in the database.";s:8:"settings";a:1:{s:10:"max_length";i:255;}s:17:"instance_settings";a:1:{s:15:"text_processing";i:0;}s:14:"default_widget";s:14:"text_textfield";s:17:"default_formatter";s:12:"text_default";s:6:"module";s:4:"text";}s:9:"text_long";a:7:{s:5:"label";s:9:"Long text";s:11:"description";s:44:"This field stores long text in the database.";s:8:"settings";a:1:{s:10:"max_length";s:0:"";}s:17:"instance_settings";a:1:{s:15:"text_processing";i:0;}s:14:"default_widget";s:13:"text_textarea";s:17:"default_formatter";s:12:"text_default";s:6:"module";s:4:"text";}s:17:"text_with_summary";a:7:{s:5:"label";s:21:"Long text and summary";s:11:"description";s:77:"This field stores long text in the database along with optional summary text.";s:8:"settings";a:1:{s:10:"max_length";s:0:"";}s:17:"instance_settings";a:2:{s:15:"text_processing";i:1;s:15:"display_summary";i:0;}s:14:"default_widget";s:26:"text_textarea_with_summary";s:17:"default_formatter";s:23:"text_summary_or_trimmed";s:6:"module";s:4:"text";}}s:12:"widget types";a:7:{s:6:"number";a:4:{s:5:"label";s:10:"Text field";s:11:"field types";a:3:{i:0;s:14:"number_integer";i:1;s:14:"number_decimal";i:2;s:12:"number_float";}s:9:"behaviors";a:2:{s:15:"multiple values";i:2;s:13:"default value";i:2;}s:6:"module";s:6:"number";}s:14:"options_select";a:4:{s:5:"label";s:11:"Select list";s:11:"field types";a:4:{i:0;s:4:"list";i:1;s:12:"list_boolean";i:2;s:9:"list_text";i:3;s:11:"list_number";}s:9:"behaviors";a:2:{s:15:"multiple values";i:4;s:13:"default value";i:2;}s:6:"module";s:7:"options";}s:15:"options_buttons";a:4:{s:5:"label";s:25:"Check boxes/radio buttons";s:11:"field types";a:4:{i:0;s:4:"list";i:1;s:12:"list_boolean";i:2;s:9:"list_text";i:3;s:11:"list_number";}s:9:"behaviors";a:2:{s:15:"multiple values";i:4;s:13:"default value";i:2;}s:6:"module";s:7:"options";}s:13:"options_onoff";a:4:{s:5:"label";s:22:"Single on/off checkbox";s:11:"field types";a:1:{i:0;s:12:"list_boolean";}s:9:"behaviors";a:2:{s:15:"multiple values";i:4;s:13:"default value";i:2;}s:6:"module";s:7:"options";}s:14:"text_textfield";a:5:{s:5:"label";s:10:"Text field";s:11:"field types";a:1:{i:0;s:4:"text";}s:8:"settings";a:1:{s:4:"size";i:60;}s:9:"behaviors";a:2:{s:15:"multiple values";i:2;s:13:"default value";i:2;}s:6:"module";s:4:"text";}s:13:"text_textarea";a:5:{s:5:"label";s:25:"Text area (multiple rows)";s:11:"field types";a:1:{i:0;s:9:"text_long";}s:8:"settings";a:1:{s:4:"rows";i:5;}s:9:"behaviors";a:2:{s:15:"multiple values";i:2;s:13:"default value";i:2;}s:6:"module";s:4:"text";}s:26:"text_textarea_with_summary";a:5:{s:5:"label";s:24:"Text area with a summary";s:11:"field types";a:1:{i:0;s:17:"text_with_summary";}s:8:"settings";a:2:{s:4:"rows";i:20;s:12:"summary_rows";i:5;}s:9:"behaviors";a:2:{s:15:"multiple values";i:2;s:13:"default value";i:2;}s:6:"module";s:4:"text";}}s:15:"formatter types";a:9:{s:12:"list_default";a:4:{s:5:"label";s:7:"Default";s:11:"field types";a:4:{i:0;s:4:"list";i:1;s:12:"list_boolean";i:2;s:9:"list_text";i:3;s:11:"list_number";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"list";}s:8:"list_key";a:4:{s:5:"label";s:3:"Key";s:11:"field types";a:4:{i:0;s:4:"list";i:1;s:12:"list_boolean";i:2;s:9:"list_text";i:3;s:11:"list_number";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"list";}s:14:"number_integer";a:5:{s:5:"label";s:7:"default";s:11:"field types";a:1:{i:0;s:14:"number_integer";}s:8:"settings";a:4:{s:18:"thousand_separator";s:1:" ";s:17:"decimal_separator";s:1:".";s:5:"scale";i:0;s:13:"prefix_suffix";b:1;}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:6:"number";}s:14:"number_decimal";a:5:{s:5:"label";s:7:"default";s:11:"field types";a:2:{i:0;s:14:"number_decimal";i:1;s:12:"number_float";}s:8:"settings";a:4:{s:18:"thousand_separator";s:1:" ";s:17:"decimal_separator";s:1:".";s:5:"scale";i:2;s:13:"prefix_suffix";b:1;}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:6:"number";}s:18:"number_unformatted";a:4:{s:5:"label";s:11:"unformatted";s:11:"field types";a:3:{i:0;s:14:"number_integer";i:1;s:14:"number_decimal";i:2;s:12:"number_float";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:6:"number";}s:12:"text_default";a:4:{s:5:"label";s:7:"Default";s:11:"field types";a:3:{i:0;s:4:"text";i:1;s:9:"text_long";i:2;s:17:"text_with_summary";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"text";}s:10:"text_plain";a:4:{s:5:"label";s:10:"Plain text";s:11:"field types";a:3:{i:0;s:4:"text";i:1;s:9:"text_long";i:2;s:17:"text_with_summary";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"text";}s:12:"text_trimmed";a:4:{s:5:"label";s:7:"Trimmed";s:11:"field types";a:3:{i:0;s:4:"text";i:1;s:9:"text_long";i:2;s:17:"text_with_summary";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"text";}s:23:"text_summary_or_trimmed";a:4:{s:5:"label";s:18:"Summary or trimmed";s:11:"field types";a:1:{i:0;s:17:"text_with_summary";}s:9:"behaviors";a:1:{s:15:"multiple values";i:2;}s:6:"module";s:4:"text";}}s:15:"fieldable types";a:3:{s:4:"node";a:7:{s:4:"name";s:4:"Node";s:6:"id key";s:3:"nid";s:12:"revision key";s:3:"vid";s:10:"bundle key";s:4:"type";s:7:"bundles";a:2:{s:7:"article";s:7:"Article";s:4:"page";s:4:"Page";}s:9:"cacheable";b:1;s:6:"module";s:4:"node";}s:13:"taxonomy_term";a:7:{s:4:"name";s:13:"Taxonomy term";s:6:"id key";s:3:"tid";s:10:"bundle key";s:23:"vocabulary_machine_name";s:7:"bundles";a:1:{s:0:"";s:4:"Tags";}s:12:"revision key";s:0:"";s:9:"cacheable";b:1;s:6:"module";s:8:"taxonomy";}s:4:"user";a:7:{s:4:"name";s:4:"User";s:6:"id key";s:3:"uid";s:12:"revision key";s:0:"";s:10:"bundle key";s:0:"";s:9:"cacheable";b:1;s:7:"bundles";a:1:{s:4:"user";s:4:"User";}s:6:"module";s:4:"user";}}}', '0', '1246392170', NULL, 1),
('field_info_fields', 'a:2:{s:6:"fields";a:1:{s:4:"body";a:12:{s:2:"id";s:1:"1";s:10:"field_name";s:4:"body";s:4:"type";s:17:"text_with_summary";s:6:"locked";s:1:"0";s:6:"module";s:4:"text";s:11:"cardinality";s:1:"1";s:6:"active";s:1:"1";s:7:"deleted";s:1:"0";s:8:"settings";a:1:{s:10:"max_length";s:0:"";}s:7:"indexes";a:1:{s:6:"format";a:1:{i:0;s:6:"format";}}s:7:"columns";a:3:{s:5:"value";a:3:{s:4:"type";s:4:"text";s:4:"size";s:3:"big";s:8:"not null";b:0;}s:7:"summary";a:3:{s:4:"type";s:4:"text";s:4:"size";s:3:"big";s:8:"not null";b:0;}s:6:"format";a:3:{s:4:"type";s:3:"int";s:8:"unsigned";b:1;s:8:"not null";b:0;}}s:7:"bundles";a:2:{i:0;s:7:"article";i:1;s:4:"page";}}}s:9:"instances";a:4:{s:7:"article";a:1:{s:4:"body";a:13:{s:5:"label";s:4:"Body";s:11:"widget_type";s:26:"text_textarea_with_summary";s:8:"settings";a:2:{s:15:"display_summary";b:1;s:15:"text_processing";i:1;}s:7:"display";a:2:{s:4:"full";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:12:"text_default";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}s:6:"teaser";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:23:"text_summary_or_trimmed";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}}s:6:"widget";a:4:{s:8:"settings";a:2:{s:4:"rows";i:20;s:12:"summary_rows";i:5;}s:6:"module";s:4:"text";s:6:"active";s:1:"1";s:4:"type";s:26:"text_textarea_with_summary";}s:8:"required";b:0;s:11:"description";s:0:"";s:2:"id";s:1:"2";s:8:"field_id";s:1:"1";s:10:"field_name";s:4:"body";s:6:"bundle";s:7:"article";s:6:"weight";s:1:"0";s:7:"deleted";s:1:"0";}}s:4:"page";a:1:{s:4:"body";a:13:{s:5:"label";s:4:"Body";s:11:"widget_type";s:26:"text_textarea_with_summary";s:8:"settings";a:2:{s:15:"display_summary";b:1;s:15:"text_processing";i:1;}s:7:"display";a:2:{s:4:"full";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:12:"text_default";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}s:6:"teaser";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:23:"text_summary_or_trimmed";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}}s:6:"widget";a:4:{s:8:"settings";a:2:{s:4:"rows";i:20;s:12:"summary_rows";i:5;}s:6:"module";s:4:"text";s:6:"active";s:1:"1";s:4:"type";s:26:"text_textarea_with_summary";}s:8:"required";b:0;s:11:"description";s:0:"";s:2:"id";s:1:"1";s:8:"field_id";s:1:"1";s:10:"field_name";s:4:"body";s:6:"bundle";s:4:"page";s:6:"weight";s:1:"0";s:7:"deleted";s:1:"0";}}s:0:"";a:0:{}s:4:"user";a:0:{}}}', '0', '1246392170', NULL, 1),
('field:user:1', 'a:0:{}', '0', '1246392170', NULL, 1);
/*!40000 ALTER TABLE cache_field ENABLE KEYS */;

--
-- Table structure for table 'cache_filter'
--

CREATE TABLE IF NOT EXISTS `cache_filter` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_form'
--

CREATE TABLE IF NOT EXISTS `cache_form` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_menu'
--

CREATE TABLE IF NOT EXISTS `cache_menu` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_page'
--

CREATE TABLE IF NOT EXISTS `cache_page` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_path'
--

CREATE TABLE IF NOT EXISTS `cache_path` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_registry'
--

CREATE TABLE IF NOT EXISTS `cache_registry` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Table structure for table 'cache_update'
--

CREATE TABLE IF NOT EXISTS `cache_update` (
  `cid` varchar(255) NOT NULL default '' COMMENT 'Primary Key: Unique cache ID.',
  `data` longblob COMMENT 'A collection of data to cache.',
  `expire` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry should expire, or 0 for never.',
  `created` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when the cache entry was created.',
  `headers` text COMMENT 'Any custom HTTP headers to be added to cached data.',
  `serialized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate whether content is serialized (1) or not (0).',
  PRIMARY KEY  (`cid`),
  KEY `expire` (`expire`)
);

--
-- Dumping data for table 'cache_update'
--

/*!40000 ALTER TABLE cache_update DISABLE KEYS */;
INSERT INTO `cache_update` VALUES
('update_project_projects', 'a:1:{s:6:"drupal";a:5:{s:4:"name";s:6:"drupal";s:4:"info";a:11:{s:4:"name";s:5:"Block";s:11:"description";s:62:"Controls the boxes that are displayed around the main content.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:12:"block.module";i:1;s:15:"block.admin.inc";i:2;s:13:"block.install";i:3;s:10:"block.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";s:7:"project";s:6:"drupal";s:16:"_info_file_ctime";i:1245675227;}s:9:"datestamp";i:0;s:8:"includes";a:19:{s:5:"block";s:5:"Block";s:5:"color";s:5:"Color";s:7:"comment";s:7:"Comment";s:5:"dblog";s:16:"Database logging";s:5:"field";s:5:"Field";s:17:"field_sql_storage";s:17:"Field SQL storage";s:6:"filter";s:6:"Filter";s:4:"help";s:4:"Help";s:4:"list";s:4:"List";s:4:"menu";s:4:"Menu";s:4:"node";s:4:"Node";s:6:"number";s:6:"Number";s:7:"options";s:7:"Options";s:6:"system";s:6:"System";s:8:"taxonomy";s:8:"Taxonomy";s:4:"text";s:4:"Text";s:6:"update";s:13:"Update status";s:4:"user";s:4:"User";s:7:"garland";s:7:"Garland";}s:12:"project_type";s:4:"core";}}', '1246395770', '1246392170', NULL, 1);
/*!40000 ALTER TABLE cache_update ENABLE KEYS */;

--
-- Table structure for table 'comment'
--

CREATE TABLE IF NOT EXISTS `comment` (
  `cid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique comment ID.',
  `pid` int(11) NOT NULL default '0' COMMENT 'The comment.cid to which this comment is a reply. If set to 0, this comment is not a reply to an existing comment.',
  `nid` int(11) NOT NULL default '0' COMMENT 'The node.nid to which this comment is a reply.',
  `uid` int(11) NOT NULL default '0' COMMENT 'The users.uid who authored the comment. If set to 0, this comment was created by an anonymous user.',
  `subject` varchar(64) NOT NULL default '' COMMENT 'The comment title.',
  `comment` longtext NOT NULL COMMENT 'The comment body.',
  `hostname` varchar(128) NOT NULL default '' COMMENT 'The author’s host name.',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'The time that the comment was created, or last edited by its author, as a Unix timestamp.',
  `status` tinyint(3) unsigned NOT NULL default '1' COMMENT 'The published status of a comment. (0 = Not Published, 1 = Published)',
  `format` smallint(6) NOT NULL default '0' COMMENT 'The filter_format.format of the comment body.',
  `thread` varchar(255) NOT NULL COMMENT 'The vancode representation of the comment’s place in a thread.',
  `name` varchar(60) default NULL COMMENT 'The comment author’s name. Uses users.name if the user is logged in, otherwise uses the value typed into the comment form.',
  `mail` varchar(64) default NULL COMMENT 'The comment author’s e-mail address from the comment form, if user is anonymous, and the ’Anonymous users may/must leave their contact information’ setting is turned on.',
  `homepage` varchar(255) default NULL COMMENT 'The comment author’s home page address from the comment form, if user is anonymous, and the ’Anonymous users may/must leave their contact information’ setting is turned on.',
  PRIMARY KEY  (`cid`),
  KEY `comment_status_pid` (`pid`,`status`),
  KEY `comment_num_new` (`nid`,`timestamp`,`status`)
);

--
-- Dumping data for table 'comment'
--

/*!40000 ALTER TABLE comment DISABLE KEYS */;
/*!40000 ALTER TABLE comment ENABLE KEYS */;

--
-- Table structure for table 'field_config'
--

CREATE TABLE IF NOT EXISTS `field_config` (
  `id` int(11) NOT NULL auto_increment COMMENT 'The primary identifier for a field',
  `field_name` varchar(32) NOT NULL COMMENT 'The name of this field. Non-deleted field names are unique, but multiple deleted fields can have the same name.',
  `type` varchar(128) NOT NULL COMMENT 'The type of this field, coming from a field module',
  `locked` tinyint(4) NOT NULL default '0' COMMENT '@TODO',
  `data` mediumtext NOT NULL COMMENT 'Field specific settings, for example maximum length',
  `module` varchar(128) NOT NULL default '',
  `cardinality` tinyint(4) NOT NULL default '0',
  `active` tinyint(4) NOT NULL default '0',
  `deleted` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `field_name` (`field_name`),
  KEY `active_deleted` (`active`,`deleted`),
  KEY `module` (`module`),
  KEY `type` (`type`)
);

--
-- Dumping data for table 'field_config'
--

/*!40000 ALTER TABLE field_config DISABLE KEYS */;
INSERT INTO `field_config` VALUES
('1', 'body', 'text_with_summary', '0', 'a:3:{s:11:"cardinality";i:1;s:8:"settings";a:1:{s:10:"max_length";s:0:"";}s:7:"indexes";a:1:{s:6:"format";a:1:{i:0;s:6:"format";}}}', 'text', '1', '1', '0');
/*!40000 ALTER TABLE field_config ENABLE KEYS */;

--
-- Table structure for table 'field_config_entity_type'
--

CREATE TABLE IF NOT EXISTS `field_config_entity_type` (
  `etid` int(10) unsigned NOT NULL auto_increment COMMENT 'The unique id for this entity type',
  `type` varchar(255) NOT NULL COMMENT 'An entity type',
  PRIMARY KEY  (`etid`),
  UNIQUE KEY `type` (`type`)
);

--
-- Dumping data for table 'field_config_entity_type'
--

/*!40000 ALTER TABLE field_config_entity_type DISABLE KEYS */;
INSERT INTO `field_config_entity_type` VALUES
('1', 'user');
/*!40000 ALTER TABLE field_config_entity_type ENABLE KEYS */;

--
-- Table structure for table 'field_config_instance'
--

CREATE TABLE IF NOT EXISTS `field_config_instance` (
  `id` int(11) NOT NULL auto_increment COMMENT 'The primary identifier for a field instance',
  `field_id` int(11) NOT NULL COMMENT 'The identifier of the field attached by this instance',
  `field_name` varchar(32) NOT NULL default '',
  `bundle` varchar(128) NOT NULL default '',
  `widget_type` varchar(128) NOT NULL default '',
  `widget_module` varchar(128) NOT NULL default '',
  `widget_active` tinyint(4) NOT NULL default '0',
  `data` mediumtext NOT NULL,
  `weight` int(11) NOT NULL default '0',
  `deleted` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `field_id_bundle` (`field_id`,`bundle`),
  KEY `widget_active_deleted` (`widget_active`,`deleted`),
  KEY `widget_module` (`widget_module`),
  KEY `widget_type` (`widget_type`)
);

--
-- Dumping data for table 'field_config_instance'
--

/*!40000 ALTER TABLE field_config_instance DISABLE KEYS */;
INSERT INTO `field_config_instance` VALUES
('1', '1', 'body', 'page', 'text_textarea_with_summary', 'text', '1', 'a:7:{s:5:"label";s:4:"Body";s:11:"widget_type";s:26:"text_textarea_with_summary";s:8:"settings";a:2:{s:15:"display_summary";b:1;s:15:"text_processing";i:1;}s:7:"display";a:2:{s:4:"full";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:12:"text_default";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}s:6:"teaser";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:23:"text_summary_or_trimmed";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}}s:6:"widget";a:3:{s:8:"settings";a:2:{s:4:"rows";i:20;s:12:"summary_rows";i:5;}s:6:"module";s:4:"text";s:6:"active";b:1;}s:8:"required";b:0;s:11:"description";s:0:"";}', '0', '0'),
('2', '1', 'body', 'article', 'text_textarea_with_summary', 'text', '1', 'a:7:{s:5:"label";s:4:"Body";s:11:"widget_type";s:26:"text_textarea_with_summary";s:8:"settings";a:2:{s:15:"display_summary";b:1;s:15:"text_processing";i:1;}s:7:"display";a:2:{s:4:"full";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:12:"text_default";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}s:6:"teaser";a:5:{s:5:"label";s:6:"hidden";s:4:"type";s:23:"text_summary_or_trimmed";s:7:"exclude";i:0;s:8:"settings";a:0:{}s:6:"module";s:4:"text";}}s:6:"widget";a:3:{s:8:"settings";a:2:{s:4:"rows";i:20;s:12:"summary_rows";i:5;}s:6:"module";s:4:"text";s:6:"active";b:1;}s:8:"required";b:0;s:11:"description";s:0:"";}', '0', '0');
/*!40000 ALTER TABLE field_config_instance ENABLE KEYS */;

--
-- Table structure for table 'field_data_body_1'
--

CREATE TABLE IF NOT EXISTS `field_data_body_1` (
  `etid` int(10) unsigned NOT NULL COMMENT 'The entity type id this data is attached to',
  `bundle` varchar(32) NOT NULL default '' COMMENT 'The field instance bundle to which this row belongs, used when deleting a field instance',
  `deleted` tinyint(4) NOT NULL default '0' COMMENT 'A boolean indicating whether this data item has been deleted',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'The entity id this data is attached to',
  `revision_id` int(10) unsigned default NULL COMMENT 'The entity revision id this data is attached to, or NULL if the entity type is not versioned',
  `delta` int(10) unsigned NOT NULL COMMENT 'The sequence number for this data item, used for multi-value fields',
  `body_value` longtext,
  `body_summary` longtext,
  `body_format` int(10) unsigned default NULL,
  PRIMARY KEY  (`etid`,`entity_id`,`deleted`,`delta`),
  KEY `body_format` (`body_format`)
);

--
-- Dumping data for table 'field_data_body_1'
--

/*!40000 ALTER TABLE field_data_body_1 DISABLE KEYS */;
/*!40000 ALTER TABLE field_data_body_1 ENABLE KEYS */;

--
-- Table structure for table 'field_revision_body_1'
--

CREATE TABLE IF NOT EXISTS `field_revision_body_1` (
  `etid` int(10) unsigned NOT NULL COMMENT 'The entity type id this data is attached to',
  `bundle` varchar(32) NOT NULL default '' COMMENT 'The field instance bundle to which this row belongs, used when deleting a field instance',
  `deleted` tinyint(4) NOT NULL default '0' COMMENT 'A boolean indicating whether this data item has been deleted',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'The entity id this data is attached to',
  `revision_id` int(10) unsigned NOT NULL default '0' COMMENT 'The entity revision id this data is attached to, or NULL if the entity type is not versioned',
  `delta` int(10) unsigned NOT NULL COMMENT 'The sequence number for this data item, used for multi-value fields',
  `body_value` longtext,
  `body_summary` longtext,
  `body_format` int(10) unsigned default NULL,
  PRIMARY KEY  (`etid`,`revision_id`,`deleted`,`delta`),
  KEY `body_format` (`body_format`)
);

--
-- Dumping data for table 'field_revision_body_1'
--

/*!40000 ALTER TABLE field_revision_body_1 DISABLE KEYS */;
/*!40000 ALTER TABLE field_revision_body_1 ENABLE KEYS */;

--
-- Table structure for table 'files'
--

CREATE TABLE IF NOT EXISTS `files` (
  `fid` int(10) unsigned NOT NULL auto_increment COMMENT 'File ID.',
  `uid` int(10) unsigned NOT NULL default '0' COMMENT 'The users.uid of the user who is associated with the file.',
  `filename` varchar(255) NOT NULL default '' COMMENT 'Name of the file with no path components. This may differ from the basename of the filepath if the file is renamed to avoid overwriting an existing file.',
  `filepath` varchar(255) NOT NULL default '' COMMENT 'Path of the file relative to Drupal root.',
  `filemime` varchar(255) NOT NULL default '' COMMENT 'The file’s MIME type.',
  `filesize` int(10) unsigned NOT NULL default '0' COMMENT 'The size of the file in bytes.',
  `status` int(11) NOT NULL default '0' COMMENT 'A bitmapped field indicating the status of the file the least sigifigant bit indicates temporary (1) or permanent (0). Temporary files older than DRUPAL_MAXIMUM_TEMP_FILE_AGE will be removed during a cron run.',
  `timestamp` int(10) unsigned NOT NULL default '0' COMMENT 'UNIX timestamp for when the file was added.',
  PRIMARY KEY  (`fid`),
  KEY `uid` (`uid`),
  KEY `status` (`status`),
  KEY `timestamp` (`timestamp`)
);

--
-- Dumping data for table 'files'
--

/*!40000 ALTER TABLE files DISABLE KEYS */;
/*!40000 ALTER TABLE files ENABLE KEYS */;

--
-- Table structure for table 'filter'
--

CREATE TABLE IF NOT EXISTS `filter` (
  `fid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Auto-incrementing filter ID.',
  `format` int(11) NOT NULL default '0' COMMENT 'Foreign key: The filter_format.format to which this filter is assigned.',
  `module` varchar(64) NOT NULL default '' COMMENT 'The origin module of the filter.',
  `delta` tinyint(4) NOT NULL default '0' COMMENT 'ID to identify which filter within module is being referenced.',
  `weight` tinyint(4) NOT NULL default '0' COMMENT 'Weight of filter within format.',
  PRIMARY KEY  (`fid`),
  UNIQUE KEY `fmd` (`format`,`module`,`delta`),
  KEY `list` (`format`,`weight`,`module`,`delta`)
);

--
-- Dumping data for table 'filter'
--

/*!40000 ALTER TABLE filter DISABLE KEYS */;
INSERT INTO `filter` VALUES
('1', '1', 'filter', '2', '0'),
('2', '1', 'filter', '0', '1'),
('3', '1', 'filter', '1', '2'),
('4', '1', 'filter', '3', '10'),
('5', '2', 'filter', '2', '0'),
('6', '2', 'filter', '1', '1'),
('7', '2', 'filter', '3', '10');
/*!40000 ALTER TABLE filter ENABLE KEYS */;

--
-- Table structure for table 'filter_format'
--

CREATE TABLE IF NOT EXISTS `filter_format` (
  `format` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique ID for format.',
  `name` varchar(255) NOT NULL default '' COMMENT 'Name of the text format (Filtered HTML).',
  `roles` varchar(255) NOT NULL default '' COMMENT 'A comma-separated string of roles; references role.rid.',
  `cache` tinyint(4) NOT NULL default '0' COMMENT 'Flag to indicate whether format is cacheable. (1 = cacheable, 0 = not cacheable)',
  `weight` tinyint(4) NOT NULL default '0' COMMENT 'Weight of text format to use when listing.',
  PRIMARY KEY  (`format`),
  UNIQUE KEY `name` (`name`)
);

--
-- Dumping data for table 'filter_format'
--

/*!40000 ALTER TABLE filter_format DISABLE KEYS */;
INSERT INTO `filter_format` VALUES
('1', 'Filtered HTML', ',1,2,', '1', '0'),
('2', 'Full HTML', '', '1', '0');
/*!40000 ALTER TABLE filter_format ENABLE KEYS */;

--
-- Table structure for table 'flood'
--

CREATE TABLE IF NOT EXISTS `flood` (
  `fid` int(11) NOT NULL auto_increment COMMENT 'Unique flood event ID.',
  `event` varchar(64) NOT NULL default '' COMMENT 'Name of event (e.g. contact).',
  `hostname` varchar(128) NOT NULL default '' COMMENT 'Hostname of the visitor.',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'Timestamp of the event.',
  PRIMARY KEY  (`fid`),
  KEY `allow` (`event`,`hostname`,`timestamp`)
);

--
-- Dumping data for table 'flood'
--

/*!40000 ALTER TABLE flood DISABLE KEYS */;
/*!40000 ALTER TABLE flood ENABLE KEYS */;

--
-- Table structure for table 'history'
--

CREATE TABLE IF NOT EXISTS `history` (
  `uid` int(11) NOT NULL default '0' COMMENT 'The users.uid that read the node nid.',
  `nid` int(11) NOT NULL default '0' COMMENT 'The node.nid that was read.',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'The Unix timestamp at which the read occurred.',
  PRIMARY KEY  (`uid`,`nid`),
  KEY `nid` (`nid`)
);

--
-- Dumping data for table 'history'
--

/*!40000 ALTER TABLE history DISABLE KEYS */;
/*!40000 ALTER TABLE history ENABLE KEYS */;

--
-- Table structure for table 'menu_custom'
--

CREATE TABLE IF NOT EXISTS `menu_custom` (
  `menu_name` varchar(32) NOT NULL default '' COMMENT 'Primary Key: Unique key for menu. This is used as a block delta so length is 32.',
  `title` varchar(255) NOT NULL default '' COMMENT 'Menu title; displayed at top of block.',
  `description` text COMMENT 'Menu description.',
  PRIMARY KEY  (`menu_name`)
);

--
-- Dumping data for table 'menu_custom'
--

/*!40000 ALTER TABLE menu_custom DISABLE KEYS */;
INSERT INTO `menu_custom` VALUES
('navigation', 'Navigation', 'The <em>Navigation</em> menu contains links such as Recent posts (if the Tracker module is enabled). Non-administrative links are added to this menu by default by modules.'),
('management', 'Management', 'The <em>Management</em> menu contains links for content creation, site building, user management, and similar site activities.'),
('user-menu', 'User menu', 'The <em>User menu</em> contains links related to the user''s account, as well as the ''Log out'' link.'),
('main-menu', 'Main menu', 'The <em>Main menu</em> is the default source for the Main links which are often used by themes to show the major sections of a site.'),
('secondary-menu', 'Secondary menu', 'The <em>Secondary menu</em> is the default source for the Secondary links which are often used for legal notices, contact details, and other navigation items that play a lesser role than the Main links.'),
('admin', 'Admin', 'The <em>Admin</em> menu contains commonly used links for administrative tasks.');
/*!40000 ALTER TABLE menu_custom ENABLE KEYS */;

--
-- Table structure for table 'menu_links'
--

CREATE TABLE IF NOT EXISTS `menu_links` (
  `menu_name` varchar(32) NOT NULL default '' COMMENT 'The menu name. All links with the same menu name (such as ’navigation’) are part of the same menu.',
  `mlid` int(10) unsigned NOT NULL auto_increment COMMENT 'The menu link ID (mlid) is the integer primary key.',
  `plid` int(10) unsigned NOT NULL default '0' COMMENT 'The parent link ID (plid) is the mlid of the link above in the hierarchy, or zero if the link is at the top level in its menu.',
  `link_path` varchar(255) NOT NULL default '' COMMENT 'The Drupal path or external path this link points to.',
  `router_path` varchar(255) NOT NULL default '' COMMENT 'For links corresponding to a Drupal path (external = 0), this connects the link to a menu_router.path for joins.',
  `link_title` varchar(255) NOT NULL default '' COMMENT 'The text displayed for the link, which may be modified by a title callback stored in menu_router.',
  `options` text COMMENT 'A serialized array of options to be passed to the url() or l() function, such as a query string or HTML attributes.',
  `module` varchar(255) NOT NULL default 'system' COMMENT 'The name of the module that generated this link.',
  `hidden` smallint(6) NOT NULL default '0' COMMENT 'A flag for whether the link should be rendered in menus. (1 = a disabled menu item that may be shown on admin screens, -1 = a menu callback, 0 = a normal, visible link)',
  `external` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate if the link points to a full URL starting with a protocol, like http:// (1 = external, 0 = internal).',
  `has_children` smallint(6) NOT NULL default '0' COMMENT 'Flag indicating whether any links have this link as a parent (1 = children exist, 0 = no children).',
  `expanded` smallint(6) NOT NULL default '0' COMMENT 'Flag for whether this link should be rendered as expanded in menus - expanded links always have their child links displayed, instead of only when the link is in the active trail (1 = expanded, 0 = not expanded)',
  `weight` int(11) NOT NULL default '0' COMMENT 'Link weight among links in the same menu at the same depth.',
  `depth` smallint(6) NOT NULL default '0' COMMENT 'The depth relative to the top level. A link with plid == 0 will have depth == 1.',
  `customized` smallint(6) NOT NULL default '0' COMMENT 'A flag to indicate that the user has manually created or edited the link (1 = customized, 0 = not customized).',
  `p1` int(10) unsigned NOT NULL default '0' COMMENT 'The first mlid in the materialized path. If N = depth, then pN must equal the mlid. If depth > 1 then p(N-1) must equal the plid. All pX where X > depth must equal zero. The columns p1 .. p9 are also called the parents.',
  `p2` int(10) unsigned NOT NULL default '0' COMMENT 'The second mlid in the materialized path. See p1.',
  `p3` int(10) unsigned NOT NULL default '0' COMMENT 'The third mlid in the materialized path. See p1.',
  `p4` int(10) unsigned NOT NULL default '0' COMMENT 'The fourth mlid in the materialized path. See p1.',
  `p5` int(10) unsigned NOT NULL default '0' COMMENT 'The fifth mlid in the materialized path. See p1.',
  `p6` int(10) unsigned NOT NULL default '0' COMMENT 'The sixth mlid in the materialized path. See p1.',
  `p7` int(10) unsigned NOT NULL default '0' COMMENT 'The seventh mlid in the materialized path. See p1.',
  `p8` int(10) unsigned NOT NULL default '0' COMMENT 'The eighth mlid in the materialized path. See p1.',
  `p9` int(10) unsigned NOT NULL default '0' COMMENT 'The ninth mlid in the materialized path. See p1.',
  `updated` smallint(6) NOT NULL default '0' COMMENT 'Flag that indicates that this link was generated during the update from Drupal 5.',
  PRIMARY KEY  (`mlid`),
  KEY `path_menu` (`link_path`(128),`menu_name`),
  KEY `menu_plid_expand_child` (`menu_name`,`plid`,`expanded`,`has_children`),
  KEY `menu_parents` (`menu_name`,`p1`,`p2`,`p3`,`p4`,`p5`,`p6`,`p7`,`p8`,`p9`),
  KEY `router_path` (`router_path`(128))
);

--
-- Dumping data for table 'menu_links'
--

/*!40000 ALTER TABLE menu_links DISABLE KEYS */;
INSERT INTO `menu_links` VALUES
('navigation', '1', '0', 'batch', 'batch', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '1', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '2', '0', 'node', 'node', 'Content', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '2', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '3', '0', 'rss.xml', 'rss.xml', 'RSS feed', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '3', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '4', '0', 'user', 'user', 'User account', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '4', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '5', '0', 'admin', 'admin', 'Administer', 'a:0:{}', 'system', 0, 0, 1, 0, '9', 1, 0, '5', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '6', '0', 'node/%', 'node/%', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '6', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '7', '0', 'field/js_add_more', 'field/js_add_more', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '7', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '8', '0', 'system/ahah', 'system/ahah', 'AHAH callback', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '8', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '9', '0', 'comment/approve', 'comment/approve', 'Approve a comment', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '9', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '10', '0', 'comment/%', 'comment/%', 'Comment permalink', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '10', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '11', '5', 'admin/compact', 'admin/compact', 'Compact mode', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 2, 0, '5', '11', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '12', '0', 'filter/tips', 'filter/tips', 'Compose tips', 'a:0:{}', 'system', 1, 0, 0, 0, '0', 1, 0, '12', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '13', '5', 'admin/content', 'admin/content', 'Content management', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:27:"Manage your site''s content.";}}', 'system', 0, 0, 1, 0, '-10', 2, 0, '5', '13', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '14', '0', 'comment/delete', 'comment/delete', 'Delete comment', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '14', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '15', '5', 'admin/development', 'admin/development', 'Development', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:18:"Development tools.";}}', 'system', 0, 0, 0, 0, '-7', 2, 0, '5', '15', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '16', '0', 'comment/edit', 'comment/edit', 'Edit comment', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '16', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '17', '0', 'system/files', 'system/files', 'File download', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '17', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '18', '5', 'admin/help', 'admin/help', 'Help', 'a:0:{}', 'system', 0, 0, 0, 0, '9', 2, 0, '5', '18', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '19', '5', 'admin/reports', 'admin/reports', 'Reports', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:59:"View reports from system logs and other status information.";}}', 'system', 0, 0, 1, 0, '5', 2, 0, '5', '19', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '20', '5', 'admin/build', 'admin/build', 'Site building', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:38:"Control how your site looks and feels.";}}', 'system', 0, 0, 1, 0, '-10', 2, 0, '5', '20', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '21', '5', 'admin/settings', 'admin/settings', 'Site configuration', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:24:"Configure site settings.";}}', 'system', 0, 0, 1, 0, '-5', 2, 0, '5', '21', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '22', '0', 'system/timezone', 'system/timezone', 'Time zone', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '22', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '23', '0', 'user/autocomplete', 'user/autocomplete', 'User autocomplete', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '23', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '24', '5', 'admin/user', 'admin/user', 'User management', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:61:"Manage your site''s users, groups and access to site features.";}}', 'system', 0, 0, 1, 0, '0', 2, 0, '5', '24', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '25', '0', 'node/add', 'node/add', 'Add new content', 'a:0:{}', 'system', 0, 0, 1, 0, '1', 1, 0, '25', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('user-menu', '26', '0', 'user/logout', 'user/logout', 'Log out', 'a:0:{}', 'system', 0, 0, 0, 0, '10', 1, 0, '26', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('user-menu', '27', '0', 'user/%', 'user/%', 'My account', 'a:0:{}', 'system', 0, 0, 0, 0, '-10', 1, 0, '27', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '28', '21', 'admin/settings/actions', 'admin/settings/actions', 'Actions', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:41:"Manage the actions defined for your site.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '28', '0', '0', '0', '0', '0', '0', 0),
('navigation', '29', '0', 'comment/reply/%', 'comment/reply/%', 'Add new comment', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '29', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '30', '20', 'admin/build/block', 'admin/build/block', 'Blocks', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:79:"Configure what block content appears in your site''s sidebars and other regions.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '30', '0', '0', '0', '0', '0', '0', 0),
('user-menu', '31', '27', 'user/%/cancel', 'user/%/cancel', 'Cancel account', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 2, 0, '27', '31', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '32', '21', 'admin/settings/clean-urls', 'admin/settings/clean-urls', 'Clean URLs', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:43:"Enable or disable clean URLs for your site.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '32', '0', '0', '0', '0', '0', '0', 0),
('management', '135', '134', 'admin/build/demo/delete/%', 'admin/build/demo/delete/%', 'Delete snapshot', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '134', '135', '0', '0', '0', '0', '0', 0),
('management', '35', '20', 'admin/build/types', 'admin/build/types', 'Content types', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:100:"Manage posts by content type, including default status, front page promotion, comment settings, etc.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '35', '0', '0', '0', '0', '0', '0', 0),
('navigation', '36', '0', 'node/%/delete', 'node/%/delete', 'Delete', 'a:0:{}', 'system', -1, 0, 0, 0, '1', 1, 0, '36', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '37', '21', 'admin/settings/file-system', 'admin/settings/file-system', 'File system', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:68:"Tell Drupal where to store uploaded files and how they are accessed.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '37', '0', '0', '0', '0', '0', '0', 0),
('management', '38', '21', 'admin/settings/ip-blocking', 'admin/settings/ip-blocking', 'IP address blocking', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:28:"Manage blocked IP addresses.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '38', '0', '0', '0', '0', '0', '0', 0),
('management', '39', '21', 'admin/settings/image-toolkit', 'admin/settings/image-toolkit', 'Image toolkit', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:74:"Choose which image toolkit to use if you have installed optional toolkits.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '39', '0', '0', '0', '0', '0', '0', 0),
('management', '40', '21', 'admin/settings/logging', 'admin/settings/logging', 'Logging and errors', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:154:"Settings for logging and alerts modules. Various modules can route Drupal''s system events to different destinations, such as syslog, database, email, etc.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '40', '0', '0', '0', '0', '0', '0', 0),
('management', '41', '21', 'admin/settings/maintenance-mode', 'admin/settings/maintenance-mode', 'Maintenance mode', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:62:"Take the site offline for maintenance or bring it back online.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '41', '0', '0', '0', '0', '0', '0', 0),
('management', '42', '20', 'admin/build/menu', 'admin/build/menu', 'Menus', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:86:"Add new menus to your site, edit existing menus, and rename and reorganize menu links.";}}', 'system', 0, 0, 1, 0, '0', 3, 0, '5', '20', '42', '0', '0', '0', '0', '0', '0', 0),
('management', '43', '20', 'admin/build/modules', 'admin/build/modules', 'Modules', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:47:"Enable or disable add-on modules for your site.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '43', '0', '0', '0', '0', '0', '0', 0),
('management', '44', '21', 'admin/settings/performance', 'admin/settings/performance', 'Performance', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:101:"Enable or disable page caching for anonymous users and set CSS and JS bandwidth optimization options.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '44', '0', '0', '0', '0', '0', '0', 0),
('management', '45', '24', 'admin/user/permissions', 'admin/user/permissions', 'Permissions', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:64:"Determine access to features by selecting permissions for roles.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '24', '45', '0', '0', '0', '0', '0', '0', 0),
('management', '46', '13', 'admin/content/rss-publishing', 'admin/content/rss-publishing', 'RSS publishing', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:114:"Configure the site description, the number of items per feed and whether feeds should be titles/teasers/full-text.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '13', '46', '0', '0', '0', '0', '0', '0', 0),
('management', '47', '21', 'admin/settings/regional-settings', 'admin/settings/regional-settings', 'Regional settings', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:90:"Settings for how Drupal displays date and time, as well as the system''s default time zone.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '47', '0', '0', '0', '0', '0', '0', 0),
('management', '48', '24', 'admin/user/roles', 'admin/user/roles', 'Roles', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:30:"List, edit, or add user roles.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '24', '48', '0', '0', '0', '0', '0', '0', 0),
('management', '49', '21', 'admin/settings/site-information', 'admin/settings/site-information', 'Site information', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:107:"Change basic site information, such as the site name, slogan, e-mail address, mission, front page and more.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '49', '0', '0', '0', '0', '0', '0', 0),
('management', '50', '19', 'admin/reports/status', 'admin/reports/status', 'Status report', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:74:"Get a status report about your site''s operation and any detected problems.";}}', 'system', 0, 0, 0, 0, '10', 3, 0, '5', '19', '50', '0', '0', '0', '0', '0', '0', 0),
('management', '51', '21', 'admin/settings/formats', 'admin/settings/formats', 'Text formats', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:127:"Configure how content input by users is filtered, including allowed HTML tags. Also allows enabling of module-provided filters.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '51', '0', '0', '0', '0', '0', '0', 0),
('management', '52', '20', 'admin/build/themes', 'admin/build/themes', 'Themes', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:57:"Change which theme your site uses or allows users to set.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '52', '0', '0', '0', '0', '0', '0', 0),
('management', '53', '21', 'admin/settings/user', 'admin/settings/user', 'Users', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:101:"Configure default behavior of users, including registration requirements, e-mails, and user pictures.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '53', '0', '0', '0', '0', '0', '0', 0),
('management', '54', '24', 'admin/user/user', 'admin/user/user', 'Users', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:26:"List, add, and edit users.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '24', '54', '0', '0', '0', '0', '0', '0', 0),
('management', '55', '18', 'admin/help/block', 'admin/help/block', 'block', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '55', '0', '0', '0', '0', '0', '0', 0),
('management', '56', '18', 'admin/help/color', 'admin/help/color', 'color', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '56', '0', '0', '0', '0', '0', '0', 0),
('management', '57', '18', 'admin/help/comment', 'admin/help/comment', 'comment', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '57', '0', '0', '0', '0', '0', '0', 0),
('management', '58', '18', 'admin/help/field', 'admin/help/field', 'field', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '58', '0', '0', '0', '0', '0', '0', 0),
('management', '59', '18', 'admin/help/field_sql_storage', 'admin/help/field_sql_storage', 'field_sql_storage', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '59', '0', '0', '0', '0', '0', '0', 0),
('management', '60', '18', 'admin/help/filter', 'admin/help/filter', 'filter', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '60', '0', '0', '0', '0', '0', '0', 0),
('management', '61', '18', 'admin/help/help', 'admin/help/help', 'help', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '61', '0', '0', '0', '0', '0', '0', 0),
('management', '62', '18', 'admin/help/menu', 'admin/help/menu', 'menu', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '62', '0', '0', '0', '0', '0', '0', 0),
('management', '63', '18', 'admin/help/node', 'admin/help/node', 'node', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '63', '0', '0', '0', '0', '0', '0', 0),
('management', '64', '18', 'admin/help/system', 'admin/help/system', 'system', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '64', '0', '0', '0', '0', '0', '0', 0),
('management', '65', '18', 'admin/help/user', 'admin/help/user', 'user', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '65', '0', '0', '0', '0', '0', '0', 0),
('management', '66', '51', 'admin/settings/formats/%', 'admin/settings/formats/%', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '51', '66', '0', '0', '0', '0', '0', 0),
('management', '67', '32', 'admin/settings/clean-urls/check', 'admin/settings/clean-urls/check', 'Clean URL check', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '32', '67', '0', '0', '0', '0', '0', 0),
('management', '68', '28', 'admin/settings/actions/configure', 'admin/settings/actions/configure', 'Configure an advanced action', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '28', '68', '0', '0', '0', '0', '0', 0),
('management', '69', '30', 'admin/build/block/configure', 'admin/build/block/configure', 'Configure block', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '30', '69', '0', '0', '0', '0', '0', 0),
('management', '70', '20', 'admin/build/menu-customize/%', 'admin/build/menu-customize/%', 'Customize menu', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '20', '70', '0', '0', '0', '0', '0', '0', 0),
('management', '71', '47', 'admin/settings/regional-settings/lookup', 'admin/settings/regional-settings/lookup', 'Date and time lookup', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '47', '71', '0', '0', '0', '0', '0', 0),
('management', '72', '30', 'admin/build/block/delete', 'admin/build/block/delete', 'Delete block', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '30', '72', '0', '0', '0', '0', '0', 0),
('management', '73', '51', 'admin/settings/formats/delete', 'admin/settings/formats/delete', 'Delete text format', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '51', '73', '0', '0', '0', '0', '0', 0),
('management', '74', '48', 'admin/user/roles/edit', 'admin/user/roles/edit', 'Edit role', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '24', '48', '74', '0', '0', '0', '0', '0', 0),
('management', '75', '38', 'admin/settings/ip-blocking/%', 'admin/settings/ip-blocking/%', 'IP address blocking', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:28:"Manage blocked IP addresses.";}}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '38', '75', '0', '0', '0', '0', '0', 0),
('management', '76', '50', 'admin/reports/status/php', 'admin/reports/status/php', 'PHP', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '19', '50', '76', '0', '0', '0', '0', '0', 0),
('management', '77', '50', 'admin/reports/status/rebuild', 'admin/reports/status/rebuild', 'Rebuild permissions', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '19', '50', '77', '0', '0', '0', '0', '0', 0),
('management', '78', '28', 'admin/settings/actions/orphan', 'admin/settings/actions/orphan', 'Remove orphans', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '28', '78', '0', '0', '0', '0', '0', 0),
('management', '79', '50', 'admin/reports/status/run-cron', 'admin/reports/status/run-cron', 'Run cron', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '19', '50', '79', '0', '0', '0', '0', '0', 0),
('management', '80', '38', 'admin/settings/ip-blocking/delete/%', 'admin/settings/ip-blocking/delete/%', 'Delete IP address', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '38', '80', '0', '0', '0', '0', '0', 0),
('management', '81', '28', 'admin/settings/actions/delete/%', 'admin/settings/actions/delete/%', 'Delete action', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:17:"Delete an action.";}}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '21', '28', '81', '0', '0', '0', '0', '0', 0),
('management', '82', '0', 'admin/build/menu-customize/%/delete', 'admin/build/menu-customize/%/delete', 'Delete menu', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '82', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '83', '30', 'admin/build/block/list/js', 'admin/build/block/list/js', 'JavaScript List Form', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '30', '83', '0', '0', '0', '0', '0', 0),
('management', '84', '43', 'admin/build/modules/list/confirm', 'admin/build/modules/list/confirm', 'List', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '43', '84', '0', '0', '0', '0', '0', 0),
('navigation', '85', '0', 'user/reset/%/%/%', 'user/reset/%/%/%', 'Reset password', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '85', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '86', '43', 'admin/build/modules/uninstall/confirm', 'admin/build/modules/uninstall/confirm', 'Uninstall', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '43', '86', '0', '0', '0', '0', '0', 0),
('navigation', '87', '0', 'node/%/revisions/%/delete', 'node/%/revisions/%/delete', 'Delete earlier revision', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '87', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '88', '0', 'node/%/revisions/%/revert', 'node/%/revisions/%/revert', 'Revert to earlier revision', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '88', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '89', '0', 'node/%/revisions/%/view', 'node/%/revisions/%/view', 'Revisions', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '89', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '90', '0', 'user/%/cancel/confirm/%/%', 'user/%/cancel/confirm/%/%', 'Confirm account cancellation', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '90', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '91', '42', 'admin/build/menu/item/%/delete', 'admin/build/menu/item/%/delete', 'Delete menu link', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '42', '91', '0', '0', '0', '0', '0', 0),
('management', '92', '42', 'admin/build/menu/item/%/edit', 'admin/build/menu/item/%/edit', 'Edit menu link', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '42', '92', '0', '0', '0', '0', '0', 0),
('management', '93', '42', 'admin/build/menu/item/%/reset', 'admin/build/menu/item/%/reset', 'Reset menu link', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '42', '93', '0', '0', '0', '0', '0', 0),
('management', '94', '42', 'admin/build/menu-customize/navigation', 'admin/build/menu-customize/%', 'Navigation', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 4, 0, '5', '20', '42', '94', '0', '0', '0', '0', '0', 0),
('management', '95', '42', 'admin/build/menu-customize/management', 'admin/build/menu-customize/%', 'Management', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 4, 0, '5', '20', '42', '95', '0', '0', '0', '0', '0', 0),
('management', '96', '42', 'admin/build/menu-customize/user-menu', 'admin/build/menu-customize/%', 'User menu', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 4, 0, '5', '20', '42', '96', '0', '0', '0', '0', '0', 0),
('management', '97', '42', 'admin/build/menu-customize/main-menu', 'admin/build/menu-customize/%', 'Main menu', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 4, 0, '5', '20', '42', '97', '0', '0', '0', '0', '0', 0),
('management', '98', '42', 'admin/build/menu-customize/secondary-menu', 'admin/build/menu-customize/%', 'Secondary menu', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 4, 0, '5', '20', '42', '98', '0', '0', '0', '0', '0', 0),
('navigation', '99', '0', 'taxonomy/autocomplete', 'taxonomy/autocomplete', 'Autocomplete taxonomy', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '99', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '147', '19', 'admin/reports/event/%', 'admin/reports/event/%', 'Details', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '19', '147', '0', '0', '0', '0', '0', '0', 0),
('management', '134', '20', 'admin/build/demo', 'admin/build/demo', 'Demonstration site', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:73:"Administer reset interval, create new dumps and manually reset this site.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '134', '0', '0', '0', '0', '0', '0', 0),
('navigation', '102', '0', 'taxonomy/term/%', 'taxonomy/term/%', 'Taxonomy term', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '102', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '146', '18', 'admin/help/dblog', 'admin/help/dblog', 'dblog', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '146', '0', '0', '0', '0', '0', '0', 0),
('management', '145', '19', 'admin/reports/page-not-found', 'admin/reports/page-not-found', 'Top ''page not found'' errors', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:36:"View ''page not found'' errors (404s).";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '19', '145', '0', '0', '0', '0', '0', '0', 0),
('management', '144', '19', 'admin/reports/access-denied', 'admin/reports/access-denied', 'Top ''access denied'' errors', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:35:"View ''access denied'' errors (403s).";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '19', '144', '0', '0', '0', '0', '0', '0', 0),
('management', '106', '18', 'admin/help/taxonomy', 'admin/help/taxonomy', 'taxonomy', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '106', '0', '0', '0', '0', '0', '0', 0),
('management', '143', '19', 'admin/reports/dblog', 'admin/reports/dblog', 'Recent log entries', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:43:"View events that have recently been logged.";}}', 'system', 0, 0, 0, 0, '-1', 3, 0, '5', '19', '143', '0', '0', '0', '0', '0', '0', 0),
('admin', '109', '0', 'node/add', 'node/add', 'Add', 'a:0:{}', 'menu', 0, 0, 0, 0, '-20', 1, 0, '109', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('navigation', '133', '0', 'demo/autocomplete', 'demo/autocomplete', 'Demo Site autocomplete', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '133', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('admin', '111', '0', 'admin', 'admin', 'Dashboard', 'a:0:{}', 'menu', 0, 0, 0, 0, '-18', 1, 0, '111', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '112', '25', 'node/add/article', 'node/add/article', 'Article', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:401:"An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.";}}', 'system', 0, 0, 0, 0, '0', 2, 0, '25', '112', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '113', '19', 'admin/reports/updates', 'admin/reports/updates', 'Available updates', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:82:"Get a status report about available updates for your installed modules and themes.";}}', 'system', 0, 0, 0, 0, '10', 3, 0, '5', '19', '113', '0', '0', '0', '0', '0', '0', 0),
('management', '114', '25', 'node/add/page', 'node/add/page', 'Page', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:299:"A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.";}}', 'system', 0, 0, 0, 0, '0', 2, 0, '25', '114', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '115', '21', 'admin/settings/updates', 'admin/settings/updates', 'Updates', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:125:"Change frequency of checks for available updates to your installed modules and themes, and how you would like to be notified.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '115', '0', '0', '0', '0', '0', '0', 0),
('management', '116', '18', 'admin/help/update', 'admin/help/update', 'update', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '18', '116', '0', '0', '0', '0', '0', '0', 0),
('navigation', '117', '0', 'node/form/js/page', 'node/form/js/page', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '117', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '118', '20', 'admin/build/node-type/article', 'admin/build/node-type/article', 'Article', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '20', '118', '0', '0', '0', '0', '0', '0', 0),
('navigation', '119', '0', 'node/form/js/article', 'node/form/js/article', '', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '119', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '120', '113', 'admin/reports/updates/check', 'admin/reports/updates/check', 'Manual update check', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '19', '113', '120', '0', '0', '0', '0', '0', 0),
('management', '121', '20', 'admin/build/node-type/page', 'admin/build/node-type/page', 'Page', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 3, 0, '5', '20', '121', '0', '0', '0', '0', '0', '0', 0),
('management', '122', '0', 'admin/build/node-type/article/delete', 'admin/build/node-type/article/delete', 'Delete', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '122', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '123', '0', 'admin/build/node-type/page/delete', 'admin/build/node-type/page/delete', 'Delete', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 1, 0, '123', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('main-menu', '124', '0', 'admin/build/menu-customize/main-menu/add', 'admin/build/menu-customize/%/add', 'Add a main menu link', 'a:0:{}', 'menu', 0, 0, 0, 0, '0', 1, 0, '124', '0', '0', '0', '0', '0', '0', '0', '0', 0),
('management', '131', '20', 'admin/build/taxonomy', 'admin/build/taxonomy', 'Taxonomy', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:67:"Manage tagging, categorization, and classification of your content.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '20', '131', '0', '0', '0', '0', '0', '0', 0),
('management', '128', '21', 'admin/settings/popups', 'admin/settings/popups', 'Popups', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:40:"Configure the page-in-a-dialog behavior.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '21', '128', '0', '0', '0', '0', '0', '0', 0),
('management', '130', '13', 'admin/content/content', 'admin/content/content', 'Content', 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:56:"View, edit, and delete your site''s content and comments.";}}', 'system', 0, 0, 0, 0, '0', 3, 0, '5', '13', '130', '0', '0', '0', '0', '0', '0', 0),
('management', '132', '131', 'admin/build/taxonomy/%', 'admin/build/taxonomy/%', 'Vocabulary', 'a:0:{}', 'system', -1, 0, 0, 0, '0', 4, 0, '5', '20', '131', '132', '0', '0', '0', '0', '0', 0);
/*!40000 ALTER TABLE menu_links ENABLE KEYS */;

--
-- Table structure for table 'menu_router'
--

CREATE TABLE IF NOT EXISTS `menu_router` (
  `path` varchar(255) NOT NULL default '' COMMENT 'Primary Key: the Drupal path this entry describes',
  `load_functions` text NOT NULL COMMENT 'A serialized array of function names (like node_load) to be called to load an object corresponding to a part of the current path.',
  `to_arg_functions` text NOT NULL COMMENT 'A serialized array of function names (like user_uid_optional_to_arg) to be called to replace a part of the router path with another string.',
  `access_callback` varchar(255) NOT NULL default '' COMMENT 'The callback which determines the access to this router path. Defaults to user_access.',
  `access_arguments` text COMMENT 'A serialized array of arguments for the access callback.',
  `page_callback` varchar(255) NOT NULL default '' COMMENT 'The name of the function that renders the page.',
  `page_arguments` text COMMENT 'A serialized array of arguments for the page callback.',
  `fit` int(11) NOT NULL default '0' COMMENT 'A numeric representation of how specific the path is.',
  `number_parts` smallint(6) NOT NULL default '0' COMMENT 'Number of parts in this router path.',
  `tab_parent` varchar(255) NOT NULL default '' COMMENT 'Only for local tasks (tabs) - the router path of the parent page (which may also be a local task).',
  `tab_root` varchar(255) NOT NULL default '' COMMENT 'Router path of the closest non-tab parent page. For pages that are not local tasks, this will be the same as the path.',
  `title` varchar(255) NOT NULL default '' COMMENT 'The title for the current page, or the title for the tab if this is a local task.',
  `title_callback` varchar(255) NOT NULL default '' COMMENT 'A function which will alter the title. Defaults to t()',
  `title_arguments` varchar(255) NOT NULL default '' COMMENT 'A serialized array of arguments for the title callback. If empty, the title will be used as the sole argument for the title callback.',
  `type` int(11) NOT NULL default '0' COMMENT 'Numeric representation of the type of the menu item, like MENU_LOCAL_TASK.',
  `block_callback` varchar(255) NOT NULL default '' COMMENT 'Name of a function used to render the block on the system administration page for this item.',
  `description` text NOT NULL COMMENT 'A description of this item.',
  `position` varchar(255) NOT NULL default '' COMMENT 'The position of the block (left or right) on the system administration page for this item.',
  `weight` int(11) NOT NULL default '0' COMMENT 'Weight of the element. Lighter weights are higher up, heavier weights go down.',
  PRIMARY KEY  (`path`),
  KEY `fit` (`fit`),
  KEY `tab_parent` (`tab_parent`)
);

--
-- Dumping data for table 'menu_router'
--

/*!40000 ALTER TABLE menu_router DISABLE KEYS */;
INSERT INTO `menu_router` VALUES
('node', '', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'node_page_default', 'a:0:{}', '1', 1, '', 'node', 'Content', 't', '', '4', '', '', '', '0'),
('rss.xml', '', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'node_feed', 'a:0:{}', '1', 1, '', 'rss.xml', 'RSS feed', 't', '', '4', '', '', '', '0'),
('batch', '', '', '1', 'a:0:{}', 'system_batch_page', 'a:0:{}', '1', 1, '', 'batch', '', 't', '', '4', '', '', '', '0'),
('user', '', '', '1', 'a:0:{}', 'user_page', 'a:0:{}', '1', 1, '', 'user', 'User account', 't', '', '4', '', '', '', '0'),
('admin', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'system_main_admin_page', 'a:0:{}', '1', 1, '', 'admin', 'Administer', 't', '', '6', '', '', '', '9'),
('user/login', '', '', 'user_is_anonymous', 'a:0:{}', 'user_page', 'a:0:{}', '3', 2, 'user', 'user', 'Log in', 't', '', '136', '', '', '', '0'),
('system/ahah', '', '', '1', 'a:0:{}', 'form_ahah_callback', 'a:0:{}', '3', 2, '', 'system/ahah', 'AHAH callback', 't', '', '4', '', '', '', '0'),
('taxonomy/autocomplete', '', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'taxonomy_autocomplete', 'a:0:{}', '3', 2, '', 'taxonomy/autocomplete', 'Autocomplete taxonomy', 't', '', '4', '', '', '', '0'),
('admin/by-module', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'system_admin_by_module', 'a:0:{}', '3', 2, 'admin', 'admin', 'By module', 't', '', '128', '', '', '', '2'),
('admin/by-task', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'system_main_admin_page', 'a:0:{}', '3', 2, 'admin', 'admin', 'By task', 't', '', '136', '', '', '', '0'),
('admin/compact', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'system_admin_compact_page', 'a:0:{}', '3', 2, '', 'admin/compact', 'Compact mode', 't', '', '4', '', '', '', '0'),
('filter/tips', '', '', '1', 'a:0:{}', 'filter_tips_long', 'a:0:{}', '3', 2, '', 'filter/tips', 'Compose tips', 't', '', '20', '', '', '', '0'),
('comment/delete', '', '', 'user_access', 'a:1:{i:0;s:19:"administer comments";}', 'comment_delete', 'a:0:{}', '3', 2, '', 'comment/delete', 'Delete comment', 't', '', '4', '', '', '', '0'),
('demo/autocomplete', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'demo_autocomplete', 'a:0:{}', '3', 2, '', 'demo/autocomplete', 'Demo Site autocomplete', 't', '', '4', '', '', '', '0'),
('comment/edit', '', '', 'user_access', 'a:1:{i:0;s:13:"post comments";}', 'comment_edit', 'a:0:{}', '3', 2, '', 'comment/edit', 'Edit comment', 't', '', '4', '', '', '', '0'),
('field/js_add_more', '', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'field_add_more_js', 'a:0:{}', '3', 2, '', 'field/js_add_more', '', 't', '', '4', '', '', '', '0'),
('system/files', '', '', '1', 'a:0:{}', 'file_download', 'a:0:{}', '3', 2, '', 'system/files', 'File download', 't', '', '4', '', '', '', '0'),
('admin/help', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_main', 'a:0:{}', '3', 2, '', 'admin/help', 'Help', 't', '', '6', '', '', '', '9'),
('system/timezone', '', '', '1', 'a:0:{}', 'system_timezone', 'a:0:{}', '3', 2, '', 'system/timezone', 'Time zone', 't', '', '4', '', '', '', '0'),
('node/add', '', '', '_node_add_access', 'a:0:{}', 'node_add_page', 'a:0:{}', '3', 2, '', 'node/add', 'Add new content', 't', '', '6', '', '', '', '1'),
('comment/approve', '', '', 'user_access', 'a:1:{i:0;s:19:"administer comments";}', 'comment_approve', 'a:1:{i:0;i:2;}', '3', 2, '', 'comment/approve', 'Approve a comment', 't', '', '4', '', '', '', '0'),
('comment/%', 'a:1:{i:1;s:12:"comment_load";}', '', 'user_access', 'a:1:{i:0;s:15:"access comments";}', 'comment_permalink', 'a:1:{i:0;i:1;}', '2', 2, '', 'comment/%', 'Comment permalink', 't', '', '4', '', '', '', '0'),
('user/register', '', '', 'user_register_access', 'a:0:{}', 'drupal_get_form', 'a:1:{i:0;s:13:"user_register";}', '3', 2, 'user', 'user', 'Create new account', 't', '', '128', '', '', '', '0'),
('user/logout', '', '', 'user_is_logged_in', 'a:0:{}', 'user_logout', 'a:0:{}', '3', 2, '', 'user/logout', 'Log out', 't', '', '6', '', '', '', '10'),
('user/password', '', '', 'user_is_anonymous', 'a:0:{}', 'drupal_get_form', 'a:1:{i:0;s:9:"user_pass";}', '3', 2, 'user', 'user', 'Request new password', 't', '', '128', '', '', '', '0'),
('user/autocomplete', '', '', 'user_access', 'a:1:{i:0;s:20:"access user profiles";}', 'user_autocomplete', 'a:0:{}', '3', 2, '', 'user/autocomplete', 'User autocomplete', 't', '', '4', '', '', '', '0'),
('admin/content', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:13:"admin/content";i:1;s:27:"access administration pages";}', 'system_admin_menu_block_page', 'a:0:{}', '3', 2, '', 'admin/content', 'Content management', 't', '', '6', '', 'Manage your site''s content.', 'left', '-10'),
('admin/development', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:17:"admin/development";i:1;s:27:"access administration pages";}', 'system_admin_menu_block_page', 'a:0:{}', '3', 2, '', 'admin/development', 'Development', 't', '', '6', '', 'Development tools.', 'right', '-7'),
('admin/reports', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:13:"admin/reports";i:1;s:19:"access site reports";}', 'system_admin_menu_block_page', 'a:0:{}', '3', 2, '', 'admin/reports', 'Reports', 't', '', '6', '', 'View reports from system logs and other status information.', 'left', '5'),
('admin/build', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:11:"admin/build";i:1;s:27:"access administration pages";}', 'system_admin_menu_block_page', 'a:0:{}', '3', 2, '', 'admin/build', 'Site building', 't', '', '6', '', 'Control how your site looks and feels.', 'right', '-10'),
('admin/settings', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:14:"admin/settings";i:1;s:27:"access administration pages";}', 'system_settings_overview', 'a:0:{}', '3', 2, '', 'admin/settings', 'Site configuration', 't', '', '6', '', 'Configure site settings.', 'right', '-5'),
('admin/user', '', '', 'system_admin_menu_block_access', 'a:2:{i:0;s:10:"admin/user";i:1;s:27:"access administration pages";}', 'system_admin_menu_block_page', 'a:0:{}', '3', 2, '', 'admin/user', 'User management', 't', '', '6', '', 'Manage your site''s users, groups and access to site features.', 'left', '0'),
('node/%', 'a:1:{i:1;s:9:"node_load";}', '', 'node_access', 'a:2:{i:0;s:4:"view";i:1;i:1;}', 'node_page_view', 'a:1:{i:0;i:1;}', '2', 2, '', 'node/%', '', 'node_page_title', 'a:1:{i:0;i:1;}', '4', '', '', '', '0'),
('user/%', 'a:1:{i:1;s:22:"user_uid_optional_load";}', 'a:1:{i:1;s:24:"user_uid_optional_to_arg";}', 'user_view_access', 'a:1:{i:0;i:1;}', 'user_view', 'a:1:{i:0;i:1;}', '2', 2, '', 'user/%', 'My account', 'user_page_title', 'a:1:{i:0;i:1;}', '6', '', '', '', '-10'),
('node/%/view', 'a:1:{i:1;s:9:"node_load";}', '', 'node_access', 'a:2:{i:0;s:4:"view";i:1;i:1;}', 'node_page_view', 'a:1:{i:0;i:1;}', '5', 3, 'node/%', 'node/%', 'View', 't', '', '136', '', '', '', '-10'),
('user/%/view', 'a:1:{i:1;s:9:"user_load";}', '', 'user_view_access', 'a:1:{i:0;i:1;}', 'user_view', 'a:1:{i:0;i:1;}', '5', 3, 'user/%', 'user/%', 'View', 't', '', '136', '', '', '', '-10'),
('admin/settings/actions', '', '', 'user_access', 'a:1:{i:0;s:18:"administer actions";}', 'system_actions_manage', 'a:0:{}', '7', 3, '', 'admin/settings/actions', 'Actions', 't', '', '6', '', 'Manage the actions defined for your site.', '', '0'),
('admin/reports/updates', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'update_status', 'a:0:{}', '7', 3, '', 'admin/reports/updates', 'Available updates', 't', '', '6', '', 'Get a status report about available updates for your installed modules and themes.', '', '10'),
('admin/build/block', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'block_admin_display', 'a:0:{}', '7', 3, '', 'admin/build/block', 'Blocks', 't', '', '6', '', 'Configure what block content appears in your site''s sidebars and other regions.', '', '0'),
('admin/build/types', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'node_overview_types', 'a:0:{}', '7', 3, '', 'admin/build/types', 'Content types', 't', '', '6', '', 'Manage posts by content type, including default status, front page promotion, comment settings, etc.', '', '0'),
('admin/settings/ip-blocking', '', '', 'user_access', 'a:1:{i:0;s:18:"block IP addresses";}', 'system_ip_blocking', 'a:0:{}', '7', 3, '', 'admin/settings/ip-blocking', 'IP address blocking', 't', '', '6', '', 'Manage blocked IP addresses.', '', '0'),
('admin/reports/dblog', '', '', 'user_access', 'a:1:{i:0;s:19:"access site reports";}', 'dblog_overview', 'a:0:{}', '7', 3, '', 'admin/reports/dblog', 'Recent log entries', 't', '', '6', '', 'View events that have recently been logged.', '', '-1'),
('admin/reports/status', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'system_status', 'a:0:{}', '7', 3, '', 'admin/reports/status', 'Status report', 't', '', '6', '', 'Get a status report about your site''s operation and any detected problems.', '', '10'),
('taxonomy/term/%', 'a:1:{i:2;s:19:"taxonomy_terms_load";}', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'taxonomy_term_page', 'a:1:{i:0;i:2;}', '6', 3, '', 'taxonomy/term/%', 'Taxonomy term', 't', '', '4', '', '', '', '0'),
('admin/help/block', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/block', 'block', 't', '', '4', '', '', '', '0'),
('admin/help/color', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/color', 'color', 't', '', '4', '', '', '', '0'),
('admin/help/comment', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/comment', 'comment', 't', '', '4', '', '', '', '0'),
('admin/help/dblog', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/dblog', 'dblog', 't', '', '4', '', '', '', '0'),
('admin/help/field', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/field', 'field', 't', '', '4', '', '', '', '0'),
('admin/help/field_sql_storage', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/field_sql_storage', 'field_sql_storage', 't', '', '4', '', '', '', '0'),
('admin/help/filter', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/filter', 'filter', 't', '', '4', '', '', '', '0'),
('admin/help/help', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/help', 'help', 't', '', '4', '', '', '', '0'),
('admin/help/menu', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/menu', 'menu', 't', '', '4', '', '', '', '0'),
('admin/help/node', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/node', 'node', 't', '', '4', '', '', '', '0'),
('admin/help/system', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/system', 'system', 't', '', '4', '', '', '', '0'),
('admin/help/taxonomy', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/taxonomy', 'taxonomy', 't', '', '4', '', '', '', '0'),
('admin/help/update', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/update', 'update', 't', '', '4', '', '', '', '0'),
('admin/help/user', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'help_page', 'a:1:{i:0;i:2;}', '7', 3, '', 'admin/help/user', 'user', 't', '', '4', '', '', '', '0'),
('comment/reply/%', 'a:1:{i:2;s:9:"node_load";}', '', 'node_access', 'a:2:{i:0;s:4:"view";i:1;i:2;}', 'comment_reply', 'a:1:{i:0;i:2;}', '6', 3, '', 'comment/reply/%', 'Add new comment', 't', '', '4', '', '', '', '0'),
('admin/settings/popups', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:21:"popups_admin_settings";}', '7', 3, '', 'admin/settings/popups', 'Popups', 't', '', '6', '', 'Configure the page-in-a-dialog behavior.', '', '0'),
('user/%/cancel', 'a:1:{i:1;s:9:"user_load";}', '', 'user_cancel_access', 'a:1:{i:0;i:1;}', 'drupal_get_form', 'a:2:{i:0;s:24:"user_cancel_confirm_form";i:1;i:1;}', '5', 3, '', 'user/%/cancel', 'Cancel account', 't', '', '4', '', '', '', '0'),
('admin/settings/clean-urls', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:25:"system_clean_url_settings";}', '7', 3, '', 'admin/settings/clean-urls', 'Clean URLs', 't', '', '6', '', 'Enable or disable clean URLs for your site.', '', '0'),
('admin/content/content', '', '', 'user_access', 'a:1:{i:0;s:16:"administer nodes";}', 'drupal_get_form', 'a:1:{i:0;s:18:"node_admin_content";}', '7', 3, '', 'admin/content/content', 'Content', 't', '', '6', '', 'View, edit, and delete your site''s content and comments.', '', '0'),
('node/%/delete', 'a:1:{i:1;s:9:"node_load";}', '', 'node_access', 'a:2:{i:0;s:6:"delete";i:1;i:1;}', 'drupal_get_form', 'a:2:{i:0;s:19:"node_delete_confirm";i:1;i:1;}', '5', 3, '', 'node/%/delete', 'Delete', 't', '', '4', '', '', '', '1'),
('admin/build/demo', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:1:{i:0;s:19:"demo_admin_settings";}', '7', 3, '', 'admin/build/demo', 'Demonstration site', 't', '', '6', '', 'Administer reset interval, create new dumps and manually reset this site.', '', '0'),
('node/%/edit', 'a:1:{i:1;s:9:"node_load";}', '', 'node_access', 'a:2:{i:0;s:6:"update";i:1;i:1;}', 'node_page_edit', 'a:1:{i:0;i:1;}', '5', 3, 'node/%', 'node/%', 'Edit', 't', '', '128', '', '', '', '1'),
('user/%/edit', 'a:1:{i:1;s:9:"user_load";}', '', 'user_edit_access', 'a:1:{i:0;i:1;}', 'user_edit', 'a:1:{i:0;i:1;}', '5', 3, 'user/%', 'user/%', 'Edit', 't', '', '128', '', '', '', '0'),
('admin/settings/file-system', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:27:"system_file_system_settings";}', '7', 3, '', 'admin/settings/file-system', 'File system', 't', '', '6', '', 'Tell Drupal where to store uploaded files and how they are accessed.', '', '0'),
('admin/settings/image-toolkit', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:29:"system_image_toolkit_settings";}', '7', 3, '', 'admin/settings/image-toolkit', 'Image toolkit', 't', '', '6', '', 'Choose which image toolkit to use if you have installed optional toolkits.', '', '0'),
('admin/settings/logging', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:23:"system_logging_settings";}', '7', 3, '', 'admin/settings/logging', 'Logging and errors', 't', '', '6', '', 'Settings for logging and alerts modules. Various modules can route Drupal''s system events to different destinations, such as syslog, database, email, etc.', '', '0'),
('admin/settings/maintenance-mode', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:28:"system_site_maintenance_mode";}', '7', 3, '', 'admin/settings/maintenance-mode', 'Maintenance mode', 't', '', '6', '', 'Take the site offline for maintenance or bring it back online.', '', '0'),
('admin/build/menu', '', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'menu_overview_page', 'a:0:{}', '7', 3, '', 'admin/build/menu', 'Menus', 't', '', '6', '', 'Add new menus to your site, edit existing menus, and rename and reorganize menu links.', '', '0'),
('admin/build/modules', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:14:"system_modules";}', '7', 3, '', 'admin/build/modules', 'Modules', 't', '', '6', '', 'Enable or disable add-on modules for your site.', '', '0'),
('admin/settings/performance', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:27:"system_performance_settings";}', '7', 3, '', 'admin/settings/performance', 'Performance', 't', '', '6', '', 'Enable or disable page caching for anonymous users and set CSS and JS bandwidth optimization options.', '', '0'),
('admin/user/permissions', '', '', 'user_access', 'a:1:{i:0;s:22:"administer permissions";}', 'drupal_get_form', 'a:1:{i:0;s:15:"user_admin_perm";}', '7', 3, '', 'admin/user/permissions', 'Permissions', 't', '', '6', '', 'Determine access to features by selecting permissions for roles.', '', '0'),
('admin/content/rss-publishing', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:25:"system_rss_feeds_settings";}', '7', 3, '', 'admin/content/rss-publishing', 'RSS publishing', 't', '', '6', '', 'Configure the site description, the number of items per feed and whether feeds should be titles/teasers/full-text.', '', '0'),
('admin/settings/regional-settings', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:24:"system_regional_settings";}', '7', 3, '', 'admin/settings/regional-settings', 'Regional settings', 't', '', '6', '', 'Settings for how Drupal displays date and time, as well as the system''s default time zone.', '', '0'),
('node/%/revisions', 'a:1:{i:1;s:9:"node_load";}', '', '_node_revision_access', 'a:1:{i:0;i:1;}', 'node_revision_overview', 'a:1:{i:0;i:1;}', '5', 3, 'node/%', 'node/%', 'Revisions', 't', '', '128', '', '', '', '2'),
('admin/user/roles', '', '', 'user_access', 'a:1:{i:0;s:22:"administer permissions";}', 'drupal_get_form', 'a:1:{i:0;s:19:"user_admin_new_role";}', '7', 3, '', 'admin/user/roles', 'Roles', 't', '', '6', '', 'List, edit, or add user roles.', '', '0'),
('admin/settings/site-information', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:32:"system_site_information_settings";}', '7', 3, '', 'admin/settings/site-information', 'Site information', 't', '', '6', '', 'Change basic site information, such as the site name, slogan, e-mail address, mission, front page and more.', '', '0'),
('admin/build/taxonomy', '', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:1:{i:0;s:30:"taxonomy_overview_vocabularies";}', '7', 3, '', 'admin/build/taxonomy', 'Taxonomy', 't', '', '6', '', 'Manage tagging, categorization, and classification of your content.', '', '0'),
('admin/settings/formats', '', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'drupal_get_form', 'a:1:{i:0;s:21:"filter_admin_overview";}', '7', 3, '', 'admin/settings/formats', 'Text formats', 't', '', '6', '', 'Configure how content input by users is filtered, including allowed HTML tags. Also allows enabling of module-provided filters.', '', '0'),
('admin/build/themes', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:18:"system_themes_form";}', '7', 3, '', 'admin/build/themes', 'Themes', 't', '', '6', '', 'Change which theme your site uses or allows users to set.', '', '0'),
('admin/reports/access-denied', '', '', 'user_access', 'a:1:{i:0;s:19:"access site reports";}', 'dblog_top', 'a:1:{i:0;s:13:"access denied";}', '7', 3, '', 'admin/reports/access-denied', 'Top ''access denied'' errors', 't', '', '6', '', 'View ''access denied'' errors (403s).', '', '0'),
('admin/reports/page-not-found', '', '', 'user_access', 'a:1:{i:0;s:19:"access site reports";}', 'dblog_top', 'a:1:{i:0;s:14:"page not found";}', '7', 3, '', 'admin/reports/page-not-found', 'Top ''page not found'' errors', 't', '', '6', '', 'View ''page not found'' errors (404s).', '', '0'),
('admin/settings/updates', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:15:"update_settings";}', '7', 3, '', 'admin/settings/updates', 'Updates', 't', '', '6', '', 'Change frequency of checks for available updates to your installed modules and themes, and how you would like to be notified.', '', '0'),
('admin/settings/user', '', '', 'user_access', 'a:1:{i:0;s:16:"administer users";}', 'drupal_get_form', 'a:1:{i:0;s:19:"user_admin_settings";}', '7', 3, '', 'admin/settings/user', 'Users', 't', '', '6', '', 'Configure default behavior of users, including registration requirements, e-mails, and user pictures.', '', '0'),
('admin/user/user', '', '', 'user_access', 'a:1:{i:0;s:16:"administer users";}', 'user_admin', 'a:1:{i:0;s:4:"list";}', '7', 3, '', 'admin/user/user', 'Users', 't', '', '6', '', 'List, add, and edit users.', '', '0'),
('node/add/article', '', '', 'node_access', 'a:2:{i:0;s:6:"create";i:1;s:7:"article";}', 'node_add', 'a:1:{i:0;i:2;}', '7', 3, '', 'node/add/article', 'Article', 'check_plain', '', '6', '', 'An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.', '', '0'),
('node/add/page', '', '', 'node_access', 'a:2:{i:0;s:6:"create";i:1;s:4:"page";}', 'node_add', 'a:1:{i:0;i:2;}', '7', 3, '', 'node/add/page', 'Page', 'check_plain', '', '6', '', 'A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.', '', '0'),
('admin/content/content/node', '', '', 'user_access', 'a:1:{i:0;s:16:"administer nodes";}', 'drupal_get_form', 'a:1:{i:0;s:18:"node_admin_content";}', '15', 4, 'admin/content/content', 'admin/content/content', 'Content', 't', '', '136', '', '', '', '-10'),
('admin/build/block/list', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'block_admin_display', 'a:0:{}', '15', 4, 'admin/build/block', 'admin/build/block', 'List', 't', '', '136', '', '', '', '-10'),
('admin/settings/formats/list', '', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'drupal_get_form', 'a:1:{i:0;s:21:"filter_admin_overview";}', '15', 4, 'admin/settings/formats', 'admin/settings/formats', 'List', 't', '', '136', '', '', '', '0'),
('admin/build/types/list', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'node_overview_types', 'a:0:{}', '15', 4, 'admin/build/types', 'admin/build/types', 'List', 't', '', '136', '', '', '', '-10'),
('admin/build/taxonomy/list', '', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:1:{i:0;s:30:"taxonomy_overview_vocabularies";}', '15', 4, 'admin/build/taxonomy', 'admin/build/taxonomy', 'List', 't', '', '136', '', '', '', '-10'),
('admin/build/modules/list', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:14:"system_modules";}', '15', 4, 'admin/build/modules', 'admin/build/modules', 'List', 't', '', '136', '', '', '', '0'),
('admin/user/user/list', '', '', 'user_access', 'a:1:{i:0;s:16:"administer users";}', 'user_admin', 'a:1:{i:0;s:4:"list";}', '15', 4, 'admin/user/user', 'admin/user/user', 'List', 't', '', '136', '', '', '', '-10'),
('admin/build/menu/list', '', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'menu_overview_page', 'a:0:{}', '15', 4, 'admin/build/menu', 'admin/build/menu', 'List menus', 't', '', '136', '', '', '', '-10'),
('admin/build/demo/maintenance', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:1:{i:0;s:19:"demo_admin_settings";}', '15', 4, 'admin/build/demo', 'admin/build/demo', 'Status', 't', '', '136', '', '', '', '0'),
('taxonomy/term/%/view', 'a:1:{i:2;s:19:"taxonomy_terms_load";}', '', 'user_access', 'a:1:{i:0;s:14:"access content";}', 'taxonomy_term_page', 'a:1:{i:0;i:2;}', '13', 4, 'taxonomy/term/%', 'taxonomy/term/%', 'View', 't', '', '136', '', '', '', '0'),
('user/%/edit/account', 'a:1:{i:1;a:1:{s:18:"user_category_load";a:2:{i:0;s:4:"%map";i:1;s:6:"%index";}}}', '', 'user_edit_access', 'a:1:{i:0;i:1;}', 'user_edit', 'a:1:{i:0;i:1;}', '11', 4, 'user/%/edit', 'user/%', 'Account', 't', '', '136', '', '', '', '0'),
('admin/build/themes/select', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:18:"system_themes_form";}', '15', 4, 'admin/build/themes', 'admin/build/themes', 'List', 't', '', '136', '', 'Select the default theme for your site.', '', '-1'),
('admin/settings/logging/settings', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:23:"system_logging_settings";}', '15', 4, 'admin/settings/logging', 'admin/settings/logging', 'Settings', 't', '', '136', '', '', '', '-1'),
('admin/settings/formats/add', '', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'filter_admin_format_page', 'a:0:{}', '15', 4, 'admin/settings/formats', 'admin/settings/formats', 'Add text format', 't', '', '128', '', '', '', '1'),
('admin/user/user/create', '', '', 'user_access', 'a:1:{i:0;s:16:"administer users";}', 'user_admin', 'a:1:{i:0;s:6:"create";}', '15', 4, 'admin/user/user', 'admin/user/user', 'Add user', 't', '', '128', '', '', '', '0'),
('admin/build/themes/settings', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:21:"system_theme_settings";}', '15', 4, 'admin/build/themes', 'admin/build/themes', 'Configure', 't', '', '128', '', '', '', '0'),
('admin/settings/regional-settings/lookup', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'system_date_time_lookup', 'a:0:{}', '15', 4, '', 'admin/settings/regional-settings/lookup', 'Date and time lookup', 't', '', '4', '', '', '', '0'),
('admin/user/roles/edit', '', '', 'user_access', 'a:1:{i:0;s:22:"administer permissions";}', 'drupal_get_form', 'a:1:{i:0;s:15:"user_admin_role";}', '15', 4, '', 'admin/user/roles/edit', 'Edit role', 't', '', '4', '', '', '', '0'),
('admin/settings/actions/manage', '', '', 'user_access', 'a:1:{i:0;s:18:"administer actions";}', 'system_actions_manage', 'a:0:{}', '15', 4, 'admin/settings/actions', 'admin/settings/actions', 'Manage actions', 't', '', '136', '', 'Manage the actions defined for your site.', '', '-2'),
('admin/reports/updates/check', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'update_manual_status', 'a:0:{}', '15', 4, '', 'admin/reports/updates/check', 'Manual update check', 't', '', '4', '', '', '', '0'),
('admin/reports/status/php', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'system_php', 'a:0:{}', '15', 4, '', 'admin/reports/status/php', 'PHP', 't', '', '4', '', '', '', '0'),
('admin/settings/actions/orphan', '', '', 'user_access', 'a:1:{i:0;s:18:"administer actions";}', 'system_actions_remove_orphans', 'a:0:{}', '15', 4, '', 'admin/settings/actions/orphan', 'Remove orphans', 't', '', '4', '', '', '', '0'),
('admin/reports/status/run-cron', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'system_run_cron', 'a:0:{}', '15', 4, '', 'admin/reports/status/run-cron', 'Run cron', 't', '', '4', '', '', '', '0'),
('admin/build/modules/uninstall', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:24:"system_modules_uninstall";}', '15', 4, 'admin/build/modules', 'admin/build/modules', 'Uninstall', 't', '', '128', '', '', '', '0'),
('admin/build/block/add', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'drupal_get_form', 'a:1:{i:0;s:20:"block_add_block_form";}', '15', 4, 'admin/build/block', 'admin/build/block', 'Add block', 't', '', '128', '', '', '', '0'),
('admin/build/types/add', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:1:{i:0;s:14:"node_type_form";}', '15', 4, 'admin/build/types', 'admin/build/types', 'Add content type', 't', '', '128', '', '', '', '0'),
('admin/build/menu/add', '', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:2:{i:0;s:14:"menu_edit_menu";i:1;s:3:"add";}', '15', 4, 'admin/build/menu', 'admin/build/menu', 'Add menu', 't', '', '128', '', '', '', '0'),
('admin/build/taxonomy/add', '', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:1:{i:0;s:24:"taxonomy_form_vocabulary";}', '15', 4, 'admin/build/taxonomy', 'admin/build/taxonomy', 'Add vocabulary', 't', '', '128', '', '', '', '0'),
('admin/build/node-type/article', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:14:"node_type_form";i:1;O:8:"stdClass":14:{s:4:"type";s:7:"article";s:4:"name";s:7:"Article";s:4:"base";s:12:"node_content";s:11:"description";s:401:"An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:7:"article";}}', '15', 4, '', 'admin/build/node-type/article', 'Article', 't', '', '4', '', '', '', '0'),
('admin/settings/clean-urls/check', '', '', '1', 'a:0:{}', 'drupal_json', 'a:1:{i:0;a:1:{s:6:"status";b:1;}}', '15', 4, '', 'admin/settings/clean-urls/check', 'Clean URL check', 't', '', '4', '', '', '', '0'),
('admin/content/content/comment', '', '', 'user_access', 'a:1:{i:0;s:19:"administer comments";}', 'comment_admin', 'a:0:{}', '15', 4, 'admin/content/content', 'admin/content/content', 'Comments', 't', '', '128', '', 'List and edit site comments and the comment approval queue.', '', '0'),
('admin/settings/actions/configure', '', '', 'user_access', 'a:1:{i:0;s:18:"administer actions";}', 'drupal_get_form', 'a:1:{i:0;s:24:"system_actions_configure";}', '15', 4, '', 'admin/settings/actions/configure', 'Configure an advanced action', 't', '', '4', '', '', '', '0'),
('admin/build/block/configure', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'drupal_get_form', 'a:1:{i:0;s:21:"block_admin_configure";}', '15', 4, '', 'admin/build/block/configure', 'Configure block', 't', '', '4', '', '', '', '0'),
('admin/build/demo/dump', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:1:{i:0;s:9:"demo_dump";}', '15', 4, 'admin/build/demo', 'admin/build/demo', 'Create snapshot', 't', '', '128', '', '', '', '2'),
('admin/build/block/delete', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'drupal_get_form', 'a:1:{i:0;s:16:"block_box_delete";}', '15', 4, '', 'admin/build/block/delete', 'Delete block', 't', '', '4', '', '', '', '0'),
('admin/settings/formats/delete', '', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'drupal_get_form', 'a:1:{i:0;s:19:"filter_admin_delete";}', '15', 4, '', 'admin/settings/formats/delete', 'Delete text format', 't', '', '4', '', '', '', '0'),
('admin/reports/event/%', 'a:1:{i:3;N;}', '', 'user_access', 'a:1:{i:0;s:19:"access site reports";}', 'dblog_event', 'a:1:{i:0;i:3;}', '14', 4, '', 'admin/reports/event/%', 'Details', 't', '', '4', '', '', '', '0'),
('taxonomy/term/%/edit', 'a:1:{i:2;s:18:"taxonomy_term_load";}', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'taxonomy_term_edit', 'a:1:{i:0;i:2;}', '13', 4, 'taxonomy/term/%', 'taxonomy/term/%', 'Edit term', 't', '', '128', '', '', '', '10'),
('admin/settings/ip-blocking/%', 'a:1:{i:3;N;}', '', 'user_access', 'a:1:{i:0;s:18:"block IP addresses";}', 'system_ip_blocking', 'a:0:{}', '14', 4, '', 'admin/settings/ip-blocking/%', 'IP address blocking', 't', '', '4', '', 'Manage blocked IP addresses.', '', '0'),
('admin/build/demo/manage', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:1:{i:0;s:11:"demo_manage";}', '15', 4, 'admin/build/demo', 'admin/build/demo', 'Manage snapshots', 't', '', '128', '', '', '', '1'),
('admin/build/node-type/page', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:14:"node_type_form";i:1;O:8:"stdClass":14:{s:4:"type";s:4:"page";s:4:"name";s:4:"Page";s:4:"base";s:12:"node_content";s:11:"description";s:299:"A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:4:"page";}}', '15', 4, '', 'admin/build/node-type/page', 'Page', 't', '', '4', '', '', '', '0'),
('admin/reports/status/rebuild', '', '', 'user_access', 'a:1:{i:0;s:27:"access administration pages";}', 'drupal_get_form', 'a:1:{i:0;s:30:"node_configure_rebuild_confirm";}', '15', 4, '', 'admin/reports/status/rebuild', 'Rebuild permissions', 't', '', '4', '', '', '', '0'),
('admin/build/demo/reset', '', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:1:{i:0;s:18:"demo_reset_confirm";}', '15', 4, 'admin/build/demo', 'admin/build/demo', 'Reset site', 't', '', '128', '', '', '', '3'),
('admin/build/menu/settings', '', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:1:{i:0;s:14:"menu_configure";}', '15', 4, 'admin/build/menu', 'admin/build/menu', 'Settings', 't', '', '128', '', '', '', '5'),
('node/form/js/article', '', '', 'node_access', 'a:2:{i:0;s:6:"create";i:1;s:7:"article";}', 'node_form_js', 'a:1:{i:0;i:3;}', '15', 4, '', 'node/form/js/article', '', 't', '', '4', '', '', '', '0'),
('node/form/js/page', '', '', 'node_access', 'a:2:{i:0;s:6:"create";i:1;s:4:"page";}', 'node_form_js', 'a:1:{i:0;i:3;}', '15', 4, '', 'node/form/js/page', '', 't', '', '4', '', '', '', '0'),
('admin/settings/formats/%', 'a:1:{i:3;s:18:"filter_format_load";}', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'filter_admin_format_page', 'a:1:{i:0;i:3;}', '14', 4, '', 'admin/settings/formats/%', '', 'filter_admin_format_title', 'a:1:{i:0;i:3;}', '4', '', '', '', '0'),
('admin/build/menu-customize/%', 'a:1:{i:3;s:9:"menu_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:2:{i:0;s:18:"menu_overview_form";i:1;i:3;}', '14', 4, '', 'admin/build/menu-customize/%', 'Customize menu', 'menu_overview_title', 'a:1:{i:0;i:3;}', '4', '', '', '', '0'),
('admin/build/taxonomy/%', 'a:1:{i:3;s:24:"taxonomy_vocabulary_load";}', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:2:{i:0;s:24:"taxonomy_form_vocabulary";i:1;i:3;}', '14', 4, '', 'admin/build/taxonomy/%', 'Vocabulary', 'taxonomy_admin_vocabulary_title_callback', 'a:1:{i:0;i:3;}', '4', '', '', '', '0'),
('admin/settings/formats/%/edit', 'a:1:{i:3;s:18:"filter_format_load";}', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'filter_admin_format_page', 'a:1:{i:0;i:3;}', '29', 5, 'admin/settings/formats/%', 'admin/settings/formats/%', 'Edit', 't', '', '136', '', '', '', '0'),
('admin/build/node-type/article/edit', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:14:"node_type_form";i:1;O:8:"stdClass":14:{s:4:"type";s:7:"article";s:4:"name";s:7:"Article";s:4:"base";s:12:"node_content";s:11:"description";s:401:"An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:7:"article";}}', '31', 5, 'admin/build/node-type/article', 'admin/build/node-type/article', 'Edit', 't', '', '136', '', '', '', '0'),
('admin/build/node-type/page/edit', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:14:"node_type_form";i:1;O:8:"stdClass":14:{s:4:"type";s:4:"page";s:4:"name";s:4:"Page";s:4:"base";s:12:"node_content";s:11:"description";s:299:"A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:4:"page";}}', '31', 5, 'admin/build/node-type/page', 'admin/build/node-type/page', 'Edit', 't', '', '136', '', '', '', '0'),
('admin/build/taxonomy/%/edit', 'a:1:{i:3;s:24:"taxonomy_vocabulary_load";}', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:2:{i:0;s:24:"taxonomy_form_vocabulary";i:1;i:3;}', '29', 5, 'admin/build/taxonomy/%', 'admin/build/taxonomy/%', 'Edit vocabulary', 't', '', '136', '', '', '', '-20'),
('admin/build/themes/settings/global', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:21:"system_theme_settings";}', '31', 5, 'admin/build/themes/settings', 'admin/build/themes', 'Global settings', 't', '', '136', '', '', '', '-1'),
('admin/build/menu-customize/%/list', 'a:1:{i:3;s:9:"menu_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:2:{i:0;s:18:"menu_overview_form";i:1;i:3;}', '29', 5, 'admin/build/menu-customize/%', 'admin/build/menu-customize/%', 'List links', 't', '', '136', '', '', '', '-10'),
('admin/content/content/comment/new', '', '', 'user_access', 'a:1:{i:0;s:19:"administer comments";}', 'comment_admin', 'a:0:{}', '31', 5, 'admin/content/content/comment', 'admin/content/content', 'Published comments', 't', '', '136', '', '', '', '-10'),
('admin/build/modules/list/confirm', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:14:"system_modules";}', '31', 5, '', 'admin/build/modules/list/confirm', 'List', 't', '', '4', '', '', '', '0'),
('admin/build/modules/uninstall/confirm', '', '', 'user_access', 'a:1:{i:0;s:29:"administer site configuration";}', 'drupal_get_form', 'a:1:{i:0;s:24:"system_modules_uninstall";}', '31', 5, '', 'admin/build/modules/uninstall/confirm', 'Uninstall', 't', '', '4', '', '', '', '0'),
('admin/content/content/comment/approval', '', '', 'user_access', 'a:1:{i:0;s:19:"administer comments";}', 'comment_admin', 'a:1:{i:0;s:8:"approval";}', '31', 5, 'admin/content/content/comment', 'admin/content/content', 'Approval queue', 't', '', '128', '', '', '', '0'),
('admin/build/node-type/article/delete', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:24:"node_type_delete_confirm";i:1;O:8:"stdClass":14:{s:4:"type";s:7:"article";s:4:"name";s:7:"Article";s:4:"base";s:12:"node_content";s:11:"description";s:401:"An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:7:"article";}}', '31', 5, '', 'admin/build/node-type/article/delete', 'Delete', 't', '', '4', '', '', '', '0'),
('admin/build/node-type/page/delete', '', '', 'user_access', 'a:1:{i:0;s:24:"administer content types";}', 'drupal_get_form', 'a:2:{i:0;s:24:"node_type_delete_confirm";i:1;O:8:"stdClass":14:{s:4:"type";s:4:"page";s:4:"name";s:4:"Page";s:4:"base";s:12:"node_content";s:11:"description";s:299:"A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.";s:4:"help";s:0:"";s:9:"has_title";s:1:"1";s:11:"title_label";s:5:"Title";s:8:"has_body";s:1:"1";s:10:"body_label";s:4:"Body";s:14:"min_word_count";s:1:"0";s:6:"custom";s:1:"1";s:8:"modified";s:1:"1";s:6:"locked";s:1:"0";s:9:"orig_type";s:4:"page";}}', '31', 5, '', 'admin/build/node-type/page/delete', 'Delete', 't', '', '4', '', '', '', '0'),
('admin/build/block/list/js', '', '', 'user_access', 'a:1:{i:0;s:17:"administer blocks";}', 'block_admin_display_js', 'a:0:{}', '31', 5, '', 'admin/build/block/list/js', 'JavaScript List Form', 't', '', '4', '', '', '', '0'),
('admin/build/menu-customize/%/add', 'a:1:{i:3;s:9:"menu_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:4:{i:0;s:14:"menu_edit_item";i:1;s:3:"add";i:2;N;i:3;i:3;}', '29', 5, 'admin/build/menu-customize/%', 'admin/build/menu-customize/%', 'Add link', 't', '', '128', '', '', '', '0'),
('admin/build/taxonomy/%/add', 'a:1:{i:3;s:24:"taxonomy_vocabulary_load";}', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:2:{i:0;s:18:"taxonomy_form_term";i:1;i:3;}', '29', 5, 'admin/build/taxonomy/%', 'admin/build/taxonomy/%', 'Add term', 't', '', '128', '', '', '', '0'),
('admin/settings/formats/%/configure', 'a:1:{i:3;s:18:"filter_format_load";}', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'filter_admin_configure_page', 'a:1:{i:0;i:3;}', '29', 5, 'admin/settings/formats/%', 'admin/settings/formats/%', 'Configure', 't', '', '128', '', '', '', '1'),
('admin/settings/ip-blocking/delete/%', 'a:1:{i:4;s:15:"blocked_ip_load";}', '', 'user_access', 'a:1:{i:0;s:18:"block IP addresses";}', 'drupal_get_form', 'a:2:{i:0;s:25:"system_ip_blocking_delete";i:1;i:4;}', '30', 5, '', 'admin/settings/ip-blocking/delete/%', 'Delete IP address', 't', '', '4', '', '', '', '0'),
('admin/build/menu-customize/%/delete', 'a:1:{i:3;s:9:"menu_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'menu_delete_menu_page', 'a:1:{i:0;i:3;}', '29', 5, '', 'admin/build/menu-customize/%/delete', 'Delete menu', 't', '', '4', '', '', '', '0'),
('admin/build/menu-customize/%/edit', 'a:1:{i:3;s:9:"menu_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:3:{i:0;s:14:"menu_edit_menu";i:1;s:4:"edit";i:2;i:3;}', '29', 5, 'admin/build/menu-customize/%', 'admin/build/menu-customize/%', 'Edit menu', 't', '', '128', '', '', '', '0'),
('admin/build/block/list/garland', '', '', '_block_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:27:"themes/garland/garland.info";s:4:"name";s:7:"garland";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"1";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:7:"Garland";s:11:"description";s:66:"Tableless, recolorable, multi-column, fluid width theme (default).";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:2:{s:3:"all";a:1:{s:9:"style.css";s:24:"themes/garland/style.css";}s:5:"print";a:1:{s:9:"print.css";s:24:"themes/garland/print.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:29:"themes/garland/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:2:{s:3:"all";a:1:{s:9:"style.css";s:24:"themes/garland/style.css";}s:5:"print";a:1:{s:9:"print.css";s:24:"themes/garland/print.css";}}s:6:"engine";s:11:"phptemplate";}}', 'block_admin_display', 'a:1:{i:0;s:7:"garland";}', '31', 5, 'admin/build/block/list', 'admin/build/block', 'Garland', 't', '', '136', '', '', '', '-10'),
('admin/build/themes/settings/garland', '', '', '_system_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:27:"themes/garland/garland.info";s:4:"name";s:7:"garland";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"1";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:7:"Garland";s:11:"description";s:66:"Tableless, recolorable, multi-column, fluid width theme (default).";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:2:{s:3:"all";a:1:{s:9:"style.css";s:24:"themes/garland/style.css";}s:5:"print";a:1:{s:9:"print.css";s:24:"themes/garland/print.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:29:"themes/garland/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:2:{s:3:"all";a:1:{s:9:"style.css";s:24:"themes/garland/style.css";}s:5:"print";a:1:{s:9:"print.css";s:24:"themes/garland/print.css";}}s:6:"engine";s:11:"phptemplate";}}', 'drupal_get_form', 'a:2:{i:0;s:21:"system_theme_settings";i:1;s:7:"garland";}', '31', 5, 'admin/build/themes/settings', 'admin/build/themes', 'Garland', 't', '', '128', '', '', '', '0'),
('admin/build/taxonomy/%/list', 'a:1:{i:3;s:24:"taxonomy_vocabulary_load";}', '', 'user_access', 'a:1:{i:0;s:19:"administer taxonomy";}', 'drupal_get_form', 'a:2:{i:0;s:23:"taxonomy_overview_terms";i:1;i:3;}', '29', 5, 'admin/build/taxonomy/%', 'admin/build/taxonomy/%', 'List terms', 't', '', '128', '', '', '', '-10'),
('admin/build/block/list/minnelli', '', '', '_block_themes_access', 'a:1:{i:0;O:8:"stdClass":11:{s:8:"filename";s:37:"themes/garland/minnelli/minnelli.info";s:4:"name";s:8:"minnelli";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"0";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:12:{s:4:"name";s:8:"Minnelli";s:11:"description";s:56:"Tableless, recolorable, multi-column, fixed width theme.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:10:"base theme";s:7:"garland";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:12:"minnelli.css";s:36:"themes/garland/minnelli/minnelli.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:38:"themes/garland/minnelli/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}s:6:"engine";s:11:"phptemplate";}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:12:"minnelli.css";s:36:"themes/garland/minnelli/minnelli.css";}}s:6:"engine";s:11:"phptemplate";s:10:"base_theme";s:7:"garland";}}', 'block_admin_display', 'a:1:{i:0;s:8:"minnelli";}', '31', 5, 'admin/build/block/list', 'admin/build/block', 'Minnelli', 't', '', '128', '', '', '', '0');
INSERT INTO `menu_router` VALUES
('admin/build/themes/settings/minnelli', '', '', '_system_themes_access', 'a:1:{i:0;O:8:"stdClass":11:{s:8:"filename";s:37:"themes/garland/minnelli/minnelli.info";s:4:"name";s:8:"minnelli";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"0";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:12:{s:4:"name";s:8:"Minnelli";s:11:"description";s:56:"Tableless, recolorable, multi-column, fixed width theme.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:10:"base theme";s:7:"garland";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:12:"minnelli.css";s:36:"themes/garland/minnelli/minnelli.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:38:"themes/garland/minnelli/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}s:6:"engine";s:11:"phptemplate";}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:12:"minnelli.css";s:36:"themes/garland/minnelli/minnelli.css";}}s:6:"engine";s:11:"phptemplate";s:10:"base_theme";s:7:"garland";}}', 'drupal_get_form', 'a:2:{i:0;s:21:"system_theme_settings";i:1;s:8:"minnelli";}', '31', 5, 'admin/build/themes/settings', 'admin/build/themes', 'Minnelli', 't', '', '128', '', '', '', '0'),
('admin/build/block/list/overlay', '', '', '_block_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:37:"sites/all/themes/overlay/overlay.info";s:4:"name";s:7:"overlay";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"1";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:15:"Overlay theming";s:11:"description";s:61:"Very simple overlay theme to resemble d7ux.org mockups later.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:9:"style.css";s:34:"sites/all/themes/overlay/style.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:39:"sites/all/themes/overlay/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:9:"style.css";s:34:"sites/all/themes/overlay/style.css";}}s:6:"engine";s:11:"phptemplate";}}', 'block_admin_display', 'a:1:{i:0;s:7:"overlay";}', '31', 5, 'admin/build/block/list', 'admin/build/block', 'Overlay theming', 't', '', '128', '', '', '', '0'),
('admin/build/themes/settings/overlay', '', '', '_system_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:37:"sites/all/themes/overlay/overlay.info";s:4:"name";s:7:"overlay";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"1";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:15:"Overlay theming";s:11:"description";s:61:"Very simple overlay theme to resemble d7ux.org mockups later.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:9:"style.css";s:34:"sites/all/themes/overlay/style.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:39:"sites/all/themes/overlay/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:9:"style.css";s:34:"sites/all/themes/overlay/style.css";}}s:6:"engine";s:11:"phptemplate";}}', 'drupal_get_form', 'a:2:{i:0;s:21:"system_theme_settings";i:1;s:7:"overlay";}', '31', 5, 'admin/build/themes/settings', 'admin/build/themes', 'Overlay theming', 't', '', '128', '', '', '', '0'),
('admin/settings/formats/%/order', 'a:1:{i:3;s:18:"filter_format_load";}', '', 'user_access', 'a:1:{i:0;s:18:"administer filters";}', 'filter_admin_order_page', 'a:1:{i:0;i:3;}', '29', 5, 'admin/settings/formats/%', 'admin/settings/formats/%', 'Rearrange', 't', '', '128', '', '', '', '2'),
('user/reset/%/%/%', 'a:3:{i:2;N;i:3;N;i:4;N;}', '', '1', 'a:0:{}', 'drupal_get_form', 'a:4:{i:0;s:15:"user_pass_reset";i:1;i:2;i:2;i:3;i:3;i:4;}', '24', 5, '', 'user/reset/%/%/%', 'Reset password', 't', '', '4', '', '', '', '0'),
('admin/build/block/list/stark', '', '', '_block_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:23:"themes/stark/stark.info";s:4:"name";s:5:"stark";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"0";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:5:"Stark";s:11:"description";s:229:"This theme demonstrates Drupal''s default HTML markup and CSS styles. To learn how to build your own theme and override Drupal''s default code, you should start reading the <a href="http://drupal.org/theme-guide">Theming Guide</a>.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:10:"layout.css";s:23:"themes/stark/layout.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:27:"themes/stark/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:10:"layout.css";s:23:"themes/stark/layout.css";}}s:6:"engine";s:11:"phptemplate";}}', 'block_admin_display', 'a:1:{i:0;s:5:"stark";}', '31', 5, 'admin/build/block/list', 'admin/build/block', 'Stark', 't', '', '128', '', '', '', '0'),
('admin/build/themes/settings/stark', '', '', '_system_themes_access', 'a:1:{i:0;O:8:"stdClass":10:{s:8:"filename";s:23:"themes/stark/stark.info";s:4:"name";s:5:"stark";s:4:"type";s:5:"theme";s:5:"owner";s:45:"themes/engines/phptemplate/phptemplate.engine";s:6:"status";s:1:"0";s:14:"schema_version";s:2:"-1";s:6:"weight";s:1:"0";s:4:"info";a:11:{s:4:"name";s:5:"Stark";s:11:"description";s:229:"This theme demonstrates Drupal''s default HTML markup and CSS styles. To learn how to build your own theme and override Drupal''s default code, you should start reading the <a href="http://drupal.org/theme-guide">Theming Guide</a>.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:10:"layout.css";s:23:"themes/stark/layout.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:27:"themes/stark/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:10:"layout.css";s:23:"themes/stark/layout.css";}}s:6:"engine";s:11:"phptemplate";}}', 'drupal_get_form', 'a:2:{i:0;s:21:"system_theme_settings";i:1;s:5:"stark";}', '31', 5, 'admin/build/themes/settings', 'admin/build/themes', 'Stark', 't', '', '128', '', '', '', '0'),
('admin/settings/actions/delete/%', 'a:1:{i:4;s:12:"actions_load";}', '', 'user_access', 'a:1:{i:0;s:18:"administer actions";}', 'drupal_get_form', 'a:2:{i:0;s:26:"system_actions_delete_form";i:1;i:4;}', '30', 5, '', 'admin/settings/actions/delete/%', 'Delete action', 't', '', '4', '', 'Delete an action.', '', '0'),
('admin/build/demo/delete/%', 'a:1:{i:4;N;}', '', 'user_access', 'a:1:{i:0;s:24:"administer demo settings";}', 'drupal_get_form', 'a:2:{i:0;s:19:"demo_delete_confirm";i:1;i:4;}', '30', 5, '', 'admin/build/demo/delete/%', 'Delete snapshot', 't', '', '4', '', '', '', '0'),
('node/%/revisions/%/delete', 'a:2:{i:1;a:1:{s:9:"node_load";a:1:{i:0;i:3;}}i:3;N;}', '', '_node_revision_access', 'a:2:{i:0;i:1;i:1;s:6:"delete";}', 'drupal_get_form', 'a:2:{i:0;s:28:"node_revision_delete_confirm";i:1;i:1;}', '21', 5, '', 'node/%/revisions/%/delete', 'Delete earlier revision', 't', '', '4', '', '', '', '0'),
('node/%/revisions/%/revert', 'a:2:{i:1;a:1:{s:9:"node_load";a:1:{i:0;i:3;}}i:3;N;}', '', '_node_revision_access', 'a:2:{i:0;i:1;i:1;s:6:"update";}', 'drupal_get_form', 'a:2:{i:0;s:28:"node_revision_revert_confirm";i:1;i:1;}', '21', 5, '', 'node/%/revisions/%/revert', 'Revert to earlier revision', 't', '', '4', '', '', '', '0'),
('node/%/revisions/%/view', 'a:2:{i:1;a:1:{s:9:"node_load";a:1:{i:0;i:3;}}i:3;N;}', '', '_node_revision_access', 'a:1:{i:0;i:1;}', 'node_show', 'a:2:{i:0;i:1;i:1;b:1;}', '21', 5, '', 'node/%/revisions/%/view', 'Revisions', 't', '', '4', '', '', '', '0'),
('admin/build/menu/item/%/delete', 'a:1:{i:4;s:14:"menu_link_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'menu_item_delete_page', 'a:1:{i:0;i:4;}', '61', 6, '', 'admin/build/menu/item/%/delete', 'Delete menu link', 't', '', '4', '', '', '', '0'),
('admin/build/menu/item/%/edit', 'a:1:{i:4;s:14:"menu_link_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:4:{i:0;s:14:"menu_edit_item";i:1;s:4:"edit";i:2;i:4;i:3;N;}', '61', 6, '', 'admin/build/menu/item/%/edit', 'Edit menu link', 't', '', '4', '', '', '', '0'),
('admin/build/menu/item/%/reset', 'a:1:{i:4;s:14:"menu_link_load";}', '', 'user_access', 'a:1:{i:0;s:15:"administer menu";}', 'drupal_get_form', 'a:2:{i:0;s:23:"menu_reset_item_confirm";i:1;i:4;}', '61', 6, '', 'admin/build/menu/item/%/reset', 'Reset menu link', 't', '', '4', '', '', '', '0'),
('user/%/cancel/confirm/%/%', 'a:3:{i:1;s:9:"user_load";i:4;N;i:5;N;}', '', 'user_cancel_access', 'a:1:{i:0;i:1;}', 'user_cancel_confirm', 'a:3:{i:0;i:1;i:1;i:4;i:2;i:5;}', '44', 6, '', 'user/%/cancel/confirm/%/%', 'Confirm account cancellation', 't', '', '4', '', '', '', '0');
/*!40000 ALTER TABLE menu_router ENABLE KEYS */;

--
-- Table structure for table 'node'
--

CREATE TABLE IF NOT EXISTS `node` (
  `nid` int(10) unsigned NOT NULL auto_increment COMMENT 'The primary identifier for a node.',
  `vid` int(10) unsigned NOT NULL default '0' COMMENT 'The current node_revision.vid version identifier.',
  `type` varchar(32) NOT NULL default '' COMMENT 'The node_type.type of this node.',
  `language` varchar(12) NOT NULL default '' COMMENT 'The languages.language of this node.',
  `title` varchar(255) NOT NULL default '' COMMENT 'The title of this node, always treated as non-markup plain text.',
  `uid` int(11) NOT NULL default '0' COMMENT 'The users.uid that owns this node; initially, this is the user that created it.',
  `status` int(11) NOT NULL default '1' COMMENT 'Boolean indicating whether the node is published (visible to non-administrators).',
  `created` int(11) NOT NULL default '0' COMMENT 'The Unix timestamp when the node was created.',
  `changed` int(11) NOT NULL default '0' COMMENT 'The Unix timestamp when the node was most recently saved.',
  `comment` int(11) NOT NULL default '0' COMMENT 'Whether comments are allowed on this node: 0 = no, 1 = closed (read only), 2 = open (read/write).',
  `promote` int(11) NOT NULL default '0' COMMENT 'Boolean indicating whether the node should be displayed on the front page.',
  `moderate` int(11) NOT NULL default '0' COMMENT 'Previously, a boolean indicating whether the node was `in moderation`; mostly no longer used.',
  `sticky` int(11) NOT NULL default '0' COMMENT 'Boolean indicating whether the node should be displayed at the top of lists in which it appears.',
  `tnid` int(10) unsigned NOT NULL default '0' COMMENT 'The translation set id for this node, which equals the node id of the source post in each set.',
  `translate` int(11) NOT NULL default '0' COMMENT 'A boolean indicating whether this translation page needs to be updated.',
  PRIMARY KEY  (`nid`),
  UNIQUE KEY `vid` (`vid`),
  KEY `node_changed` (`changed`),
  KEY `node_created` (`created`),
  KEY `node_moderate` (`moderate`),
  KEY `node_frontpage` (`promote`,`status`,`sticky`,`created`),
  KEY `node_status_type` (`status`,`type`,`nid`),
  KEY `node_title_type` (`title`,`type`(4)),
  KEY `node_type` (`type`(4)),
  KEY `uid` (`uid`),
  KEY `tnid` (`tnid`),
  KEY `translate` (`translate`)
);

--
-- Dumping data for table 'node'
--

/*!40000 ALTER TABLE node DISABLE KEYS */;
/*!40000 ALTER TABLE node ENABLE KEYS */;

--
-- Table structure for table 'node_access'
--

CREATE TABLE IF NOT EXISTS `node_access` (
  `nid` int(10) unsigned NOT NULL default '0' COMMENT 'The node.nid this record affects.',
  `gid` int(10) unsigned NOT NULL default '0' COMMENT 'The grant ID a user must possess in the specified realm to gain this row’s privileges on the node.',
  `realm` varchar(255) NOT NULL default '' COMMENT 'The realm in which the user must possess the grant ID. Each node access node can define one or more realms.',
  `grant_view` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Boolean indicating whether a user with the realm/grant pair can view this node.',
  `grant_update` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Boolean indicating whether a user with the realm/grant pair can edit this node.',
  `grant_delete` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Boolean indicating whether a user with the realm/grant pair can delete this node.',
  PRIMARY KEY  (`nid`,`gid`,`realm`)
);

--
-- Dumping data for table 'node_access'
--

/*!40000 ALTER TABLE node_access DISABLE KEYS */;
INSERT INTO `node_access` VALUES
('0', '0', 'all', '1', '0', '0');
/*!40000 ALTER TABLE node_access ENABLE KEYS */;

--
-- Table structure for table 'node_comment_statistics'
--

CREATE TABLE IF NOT EXISTS `node_comment_statistics` (
  `nid` int(10) unsigned NOT NULL default '0' COMMENT 'The node.nid for which the statistics are compiled.',
  `last_comment_timestamp` int(11) NOT NULL default '0' COMMENT 'The Unix timestamp of the last comment that was posted within this node, from comment.timestamp.',
  `last_comment_name` varchar(60) default NULL COMMENT 'The name of the latest author to post a comment on this node, from comment.name.',
  `last_comment_uid` int(11) NOT NULL default '0' COMMENT 'The user ID of the latest author to post a comment on this node, from comment.uid.',
  `comment_count` int(10) unsigned NOT NULL default '0' COMMENT 'The total number of comments on this node.',
  PRIMARY KEY  (`nid`),
  KEY `node_comment_timestamp` (`last_comment_timestamp`)
);

--
-- Dumping data for table 'node_comment_statistics'
--

/*!40000 ALTER TABLE node_comment_statistics DISABLE KEYS */;
/*!40000 ALTER TABLE node_comment_statistics ENABLE KEYS */;

--
-- Table structure for table 'node_revision'
--

CREATE TABLE IF NOT EXISTS `node_revision` (
  `nid` int(10) unsigned NOT NULL default '0' COMMENT 'The node this version belongs to.',
  `vid` int(10) unsigned NOT NULL auto_increment COMMENT 'The primary identifier for this version.',
  `uid` int(11) NOT NULL default '0' COMMENT 'The users.uid that created this version.',
  `title` varchar(255) NOT NULL default '' COMMENT 'The title of this version.',
  `log` longtext NOT NULL COMMENT 'The log entry explaining the changes in this version.',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'A Unix timestamp indicating when this version was created.',
  PRIMARY KEY  (`vid`),
  KEY `nid` (`nid`),
  KEY `uid` (`uid`)
);

--
-- Dumping data for table 'node_revision'
--

/*!40000 ALTER TABLE node_revision DISABLE KEYS */;
/*!40000 ALTER TABLE node_revision ENABLE KEYS */;

--
-- Table structure for table 'node_type'
--

CREATE TABLE IF NOT EXISTS `node_type` (
  `type` varchar(32) NOT NULL COMMENT 'The machine-readable name of this type.',
  `name` varchar(255) NOT NULL default '' COMMENT 'The human-readable name of this type.',
  `base` varchar(255) NOT NULL COMMENT 'The base string used to construct callbacks corresponding to this node type.',
  `description` mediumtext NOT NULL COMMENT 'A brief description of this type.',
  `help` mediumtext NOT NULL COMMENT 'Help information shown to the user when creating a node of this type.',
  `has_title` tinyint(3) unsigned NOT NULL COMMENT 'Boolean indicating whether this type uses the node.title field.',
  `title_label` varchar(255) NOT NULL default '' COMMENT 'The label displayed for the title field on the edit form.',
  `has_body` tinyint(3) unsigned NOT NULL COMMENT 'Boolean indicating whether this type has the body field attached.',
  `body_label` varchar(255) NOT NULL default '' COMMENT 'The label displayed for the body field on the edit form.',
  `min_word_count` smallint(5) unsigned NOT NULL COMMENT 'The minimum number of words the body must contain.',
  `custom` tinyint(4) NOT NULL default '0' COMMENT 'A boolean indicating whether this type is defined by a module (FALSE) or by a user via a module like the Content Construction Kit (TRUE).',
  `modified` tinyint(4) NOT NULL default '0' COMMENT 'A boolean indicating whether this type has been modified by an administrator; currently not used in any way.',
  `locked` tinyint(4) NOT NULL default '0' COMMENT 'A boolean indicating whether the administrator can change the machine name of this type.',
  `orig_type` varchar(255) NOT NULL default '' COMMENT 'The original machine-readable name of this node type. This may be different from the current type name if the locked field is 0.',
  PRIMARY KEY  (`type`)
);

--
-- Dumping data for table 'node_type'
--

/*!40000 ALTER TABLE node_type DISABLE KEYS */;
INSERT INTO `node_type` VALUES
('page', 'Page', 'node_content', 'A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an "About us" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site''s initial home page.', '', '1', 'Title', '1', 'Body', 0, '1', '1', '0', 'page'),
('article', 'Article', 'node_content', 'An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site''s initial home page, and provides the ability to post comments.', '', '1', 'Title', '1', 'Body', 0, '1', '1', '0', 'article');
/*!40000 ALTER TABLE node_type ENABLE KEYS */;

--
-- Table structure for table 'queue'
--

CREATE TABLE IF NOT EXISTS `queue` (
  `item_id` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique item ID.',
  `name` varchar(255) NOT NULL default '' COMMENT 'The queue name.',
  `consumer_id` int(11) NOT NULL default '0' COMMENT 'The ID of the dequeuing consumer.',
  `data` longtext COMMENT 'The arbitrary data for the item.',
  `expire` int(11) NOT NULL default '0' COMMENT 'Timestamp when the claim lease expires on the item.',
  `created` int(11) NOT NULL default '0' COMMENT 'Timestamp when the item was created.',
  PRIMARY KEY  (`item_id`),
  KEY `consumer_queue` (`consumer_id`,`name`,`created`),
  KEY `consumer_expire` (`consumer_id`,`expire`)
);

--
-- Dumping data for table 'queue'
--

/*!40000 ALTER TABLE queue DISABLE KEYS */;
/*!40000 ALTER TABLE queue ENABLE KEYS */;

--
-- Table structure for table 'queue_consumer_id'
--

CREATE TABLE IF NOT EXISTS `queue_consumer_id` (
  `consumer_id` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique consumer ID used to make sure only one consumer gets one item.',
  PRIMARY KEY  (`consumer_id`)
);

--
-- Dumping data for table 'queue_consumer_id'
--

/*!40000 ALTER TABLE queue_consumer_id DISABLE KEYS */;
/*!40000 ALTER TABLE queue_consumer_id ENABLE KEYS */;

--
-- Table structure for table 'registry'
--

CREATE TABLE IF NOT EXISTS `registry` (
  `name` varchar(255) NOT NULL default '' COMMENT 'The name of the function, class, or interface.',
  `type` varchar(9) NOT NULL default '' COMMENT 'Either function or class or interface.',
  `filename` varchar(255) NOT NULL COMMENT 'Name of the file.',
  `module` varchar(255) NOT NULL default '' COMMENT 'Name of the module the file belongs to.',
  `suffix` varchar(68) NOT NULL default '' COMMENT 'The part of the function name after the module, which is the hook this function implements, if any.',
  `weight` int(11) NOT NULL default '0' COMMENT 'The order in which this module’s hooks should be invoked relative to other modules. Equal-weighted modules are ordered by name.',
  PRIMARY KEY  (`name`,`type`),
  KEY `hook` (`type`,`suffix`,`weight`,`module`)
);

--
-- Dumping data for table 'registry'
--

/*!40000 ALTER TABLE registry DISABLE KEYS */;
INSERT INTO `registry` VALUES
('user_module_invoke', 'function', 'modules/user/user.module', 'user', 'module_invoke', '0'),
('user_theme', 'function', 'modules/user/user.module', 'user', 'theme', '0'),
('user_fieldable_info', 'function', 'modules/user/user.module', 'user', 'fieldable_info', '0'),
('user_field_build_modes', 'function', 'modules/user/user.module', 'user', 'field_build_modes', '0'),
('user_external_load', 'function', 'modules/user/user.module', 'user', 'external_load', '0'),
('user_external_login', 'function', 'modules/user/user.module', 'user', 'external_login', '0'),
('user_load_multiple', 'function', 'modules/user/user.module', 'user', 'load_multiple', '0'),
('user_load', 'function', 'modules/user/user.module', 'user', 'load', '0'),
('user_load_by_mail', 'function', 'modules/user/user.module', 'user', 'load_by_mail', '0'),
('user_load_by_name', 'function', 'modules/user/user.module', 'user', 'load_by_name', '0'),
('user_save', 'function', 'modules/user/user.module', 'user', 'save', '0'),
('user_validate_name', 'function', 'modules/user/user.module', 'user', 'validate_name', '0'),
('user_validate_mail', 'function', 'modules/user/user.module', 'user', 'validate_mail', '0'),
('user_validate_picture', 'function', 'modules/user/user.module', 'user', 'validate_picture', '0'),
('user_password', 'function', 'modules/user/user.module', 'user', 'password', '0'),
('user_role_permissions', 'function', 'modules/user/user.module', 'user', 'role_permissions', '0'),
('user_access', 'function', 'modules/user/user.module', 'user', 'access', '0'),
('user_is_blocked', 'function', 'modules/user/user.module', 'user', 'is_blocked', '0'),
('user_perm', 'function', 'modules/user/user.module', 'user', 'perm', '0'),
('user_file_download', 'function', 'modules/user/user.module', 'user', 'file_download', '0'),
('user_file_references', 'function', 'modules/user/user.module', 'user', 'file_references', '0'),
('user_file_delete', 'function', 'modules/user/user.module', 'user', 'file_delete', '0'),
('user_search', 'function', 'modules/user/user.module', 'user', 'search', '0'),
('user_elements', 'function', 'modules/user/user.module', 'user', 'elements', '0'),
('user_user_view', 'function', 'modules/user/user.module', 'user', 'user_view', '0'),
('user_user_form', 'function', 'modules/user/user.module', 'user', 'user_form', '0'),
('user_user_validate', 'function', 'modules/user/user.module', 'user', 'user_validate', '0'),
('user_user_submit', 'function', 'modules/user/user.module', 'user', 'user_submit', '0'),
('user_user_categories', 'function', 'modules/user/user.module', 'user', 'user_categories', '0'),
('user_login_block', 'function', 'modules/user/user.module', 'user', 'login_block', '0'),
('user_block_list', 'function', 'modules/user/user.module', 'user', 'block_list', '0'),
('user_block_configure', 'function', 'modules/user/user.module', 'user', 'block_configure', '0'),
('user_block_save', 'function', 'modules/user/user.module', 'user', 'block_save', '0'),
('user_block_view', 'function', 'modules/user/user.module', 'user', 'block_view', '0'),
('template_preprocess_user_picture', 'function', 'modules/user/user.module', 'user', '', '0'),
('theme_user_list', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_is_anonymous', 'function', 'modules/user/user.module', 'user', 'is_anonymous', '0'),
('user_is_logged_in', 'function', 'modules/user/user.module', 'user', 'is_logged_in', '0'),
('user_register_access', 'function', 'modules/user/user.module', 'user', 'register_access', '0'),
('user_view_access', 'function', 'modules/user/user.module', 'user', 'view_access', '0'),
('user_edit_access', 'function', 'modules/user/user.module', 'user', 'edit_access', '0'),
('user_cancel_access', 'function', 'modules/user/user.module', 'user', 'cancel_access', '0'),
('user_load_self', 'function', 'modules/user/user.module', 'user', 'load_self', '0'),
('user_menu', 'function', 'modules/user/user.module', 'user', 'menu', '0'),
('user_init', 'function', 'modules/user/user.module', 'user', 'init', '0'),
('user_uid_optional_load', 'function', 'modules/user/user.module', 'user', 'uid_optional_load', '0'),
('user_category_load', 'function', 'modules/user/user.module', 'user', 'category_load', '0'),
('user_uid_optional_to_arg', 'function', 'modules/user/user.module', 'user', 'uid_optional_to_arg', '0'),
('user_page_title', 'function', 'modules/user/user.module', 'user', 'page_title', '0'),
('user_get_authmaps', 'function', 'modules/user/user.module', 'user', 'get_authmaps', '0'),
('user_set_authmaps', 'function', 'modules/user/user.module', 'user', 'set_authmaps', '0'),
('user_login', 'function', 'modules/user/user.module', 'user', 'login', '0'),
('user_login_default_validators', 'function', 'modules/user/user.module', 'user', 'login_default_validators', '0'),
('user_login_name_validate', 'function', 'modules/user/user.module', 'user', 'login_name_validate', '0'),
('user_login_authenticate_validate', 'function', 'modules/user/user.module', 'user', 'login_authenticate_validate', '0'),
('user_login_final_validate', 'function', 'modules/user/user.module', 'user', 'login_final_validate', '0'),
('user_authenticate', 'function', 'modules/user/user.module', 'user', 'authenticate', '0'),
('user_authenticate_finalize', 'function', 'modules/user/user.module', 'user', 'authenticate_finalize', '0'),
('user_login_submit', 'function', 'modules/user/user.module', 'user', 'login_submit', '0'),
('user_external_login_register', 'function', 'modules/user/user.module', 'user', 'external_login_register', '0'),
('user_pass_reset_url', 'function', 'modules/user/user.module', 'user', 'pass_reset_url', '0'),
('user_cancel_url', 'function', 'modules/user/user.module', 'user', 'cancel_url', '0'),
('user_pass_rehash', 'function', 'modules/user/user.module', 'user', 'pass_rehash', '0'),
('user_edit_form', 'function', 'modules/user/user.module', 'user', 'edit_form', '0'),
('user_cancel', 'function', 'modules/user/user.module', 'user', 'cancel', '0'),
('_user_cancel', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_build_content', 'function', 'modules/user/user.module', 'user', 'build_content', '0'),
('user_mail', 'function', 'modules/user/user.module', 'user', 'mail', '0'),
('_user_mail_text', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_roles', 'function', 'modules/user/user.module', 'user', 'roles', '0'),
('user_user_operations', 'function', 'modules/user/user.module', 'user', 'user_operations', '0'),
('user_user_operations_unblock', 'function', 'modules/user/user.module', 'user', 'user_operations_unblock', '0'),
('user_user_operations_block', 'function', 'modules/user/user.module', 'user', 'user_operations_block', '0'),
('user_multiple_role_edit', 'function', 'modules/user/user.module', 'user', 'multiple_role_edit', '0'),
('user_multiple_cancel_confirm', 'function', 'modules/user/user.module', 'user', 'multiple_cancel_confirm', '0'),
('user_multiple_cancel_confirm_submit', 'function', 'modules/user/user.module', 'user', 'multiple_cancel_confirm_submit', '0'),
('user_help', 'function', 'modules/user/user.module', 'user', 'help', '0'),
('_user_categories', 'function', 'modules/user/user.module', 'user', '', '0'),
('_user_sort', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_filters', 'function', 'modules/user/user.module', 'user', 'filters', '0'),
('user_build_filter_query', 'function', 'modules/user/user.module', 'user', 'build_filter_query', '0'),
('user_forms', 'function', 'modules/user/user.module', 'user', 'forms', '0'),
('user_comment_view', 'function', 'modules/user/user.module', 'user', 'comment_view', '0'),
('theme_user_signature', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_mail_tokens', 'function', 'modules/user/user.module', 'user', 'mail_tokens', '0'),
('user_preferred_language', 'function', 'modules/user/user.module', 'user', 'preferred_language', '0'),
('_user_mail_notify', 'function', 'modules/user/user.module', 'user', '', '0'),
('_user_password_dynamic_validation', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_node_load', 'function', 'modules/user/user.module', 'user', 'node_load', '0'),
('user_hook_info', 'function', 'modules/user/user.module', 'user', 'hook_info', '0'),
('user_action_info', 'function', 'modules/user/user.module', 'user', 'action_info', '0'),
('user_block_user_action', 'function', 'modules/user/user.module', 'user', 'block_user_action', '0'),
('user_register_submit', 'function', 'modules/user/user.module', 'user', 'register_submit', '0'),
('user_register', 'function', 'modules/user/user.module', 'user', 'register', '0'),
('user_register_validate', 'function', 'modules/user/user.module', 'user', 'register_validate', '0'),
('_user_forms', 'function', 'modules/user/user.module', 'user', '', '0'),
('user_admin', 'function', 'modules/user/user.admin.inc', 'user', 'admin', '0'),
('user_filter_form', 'function', 'modules/user/user.admin.inc', 'user', 'filter_form', '0'),
('user_filter_form_submit', 'function', 'modules/user/user.admin.inc', 'user', 'filter_form_submit', '0'),
('user_admin_account', 'function', 'modules/user/user.admin.inc', 'user', 'admin_account', '0'),
('user_admin_account_submit', 'function', 'modules/user/user.admin.inc', 'user', 'admin_account_submit', '0'),
('user_admin_account_validate', 'function', 'modules/user/user.admin.inc', 'user', 'admin_account_validate', '0'),
('user_admin_settings', 'function', 'modules/user/user.admin.inc', 'user', 'admin_settings', '0'),
('user_admin_perm', 'function', 'modules/user/user.admin.inc', 'user', 'admin_perm', '0'),
('user_admin_perm_submit', 'function', 'modules/user/user.admin.inc', 'user', 'admin_perm_submit', '0'),
('theme_user_admin_perm', 'function', 'modules/user/user.admin.inc', 'user', '', '0'),
('user_admin_role', 'function', 'modules/user/user.admin.inc', 'user', 'admin_role', '0'),
('user_admin_role_validate', 'function', 'modules/user/user.admin.inc', 'user', 'admin_role_validate', '0'),
('user_admin_role_submit', 'function', 'modules/user/user.admin.inc', 'user', 'admin_role_submit', '0'),
('theme_user_admin_account', 'function', 'modules/user/user.admin.inc', 'user', '', '0'),
('theme_user_admin_new_role', 'function', 'modules/user/user.admin.inc', 'user', '', '0'),
('theme_user_filter_form', 'function', 'modules/user/user.admin.inc', 'user', '', '0'),
('theme_user_filters', 'function', 'modules/user/user.admin.inc', 'user', '', '0'),
('user_modules_installed', 'function', 'modules/user/user.admin.inc', 'user', 'modules_installed', '0'),
('user_cancel_confirm_form_submit', 'function', 'modules/user/user.pages.inc', 'user', 'cancel_confirm_form_submit', '0'),
('user_cancel_confirm_form', 'function', 'modules/user/user.pages.inc', 'user', 'cancel_confirm_form', '0'),
('user_edit_cancel_submit', 'function', 'modules/user/user.pages.inc', 'user', 'edit_cancel_submit', '0'),
('user_profile_form_submit', 'function', 'modules/user/user.pages.inc', 'user', 'profile_form_submit', '0'),
('user_profile_form_validate', 'function', 'modules/user/user.pages.inc', 'user', 'profile_form_validate', '0'),
('user_profile_form', 'function', 'modules/user/user.pages.inc', 'user', 'profile_form', '0'),
('user_edit', 'function', 'modules/user/user.pages.inc', 'user', 'edit', '0'),
('template_preprocess_user_profile_category', 'function', 'modules/user/user.pages.inc', 'user', '', '0'),
('template_preprocess_user_profile_item', 'function', 'modules/user/user.pages.inc', 'user', '', '0'),
('template_preprocess_user_profile', 'function', 'modules/user/user.pages.inc', 'user', '', '0'),
('user_view', 'function', 'modules/user/user.pages.inc', 'user', 'view', '0'),
('user_logout', 'function', 'modules/user/user.pages.inc', 'user', 'logout', '0'),
('user_pass_reset', 'function', 'modules/user/user.pages.inc', 'user', 'pass_reset', '0'),
('user_pass_submit', 'function', 'modules/user/user.pages.inc', 'user', 'pass_submit', '0'),
('user_pass_validate', 'function', 'modules/user/user.pages.inc', 'user', 'pass_validate', '0'),
('user_pass', 'function', 'modules/user/user.pages.inc', 'user', 'pass', '0'),
('user_autocomplete', 'function', 'modules/user/user.pages.inc', 'user', 'autocomplete', '0'),
('user_schema', 'function', 'modules/user/user.install', 'user', 'schema', '0'),
('user_update_7000', 'function', 'modules/user/user.install', 'user', 'update_7000', '0'),
('user_update_7001', 'function', 'modules/user/user.install', 'user', 'update_7001', '0'),
('user_update_7002', 'function', 'modules/user/user.install', 'user', 'update_7002', '0'),
('user_update_7003', 'function', 'modules/user/user.install', 'user', 'update_7003', '0'),
('user_update_7004', 'function', 'modules/user/user.install', 'user', 'update_7004', '0'),
('UserRegistrationTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserValidationTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserCancelTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserPictureTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserPermissionsTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserAdminTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserTimeZoneFunctionalTest', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserAutocompleteTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserBlocksUnitTests', 'class', 'modules/user/user.test', 'user', '', '0'),
('UserSaveTestCase', 'class', 'modules/user/user.test', 'user', '', '0'),
('system_send_email_action_validate', 'function', 'modules/system/system.module', 'system', 'send_email_action_validate', '0'),
('system_send_email_action_form', 'function', 'modules/system/system.module', 'system', 'send_email_action_form', '0'),
('system_actions_remove_orphans', 'function', 'modules/system/system.module', 'system', 'actions_remove_orphans', '0'),
('system_action_delete_orphans_post', 'function', 'modules/system/system.module', 'system', 'action_delete_orphans_post', '0'),
('system_actions_delete_form_submit', 'function', 'modules/system/system.module', 'system', 'actions_delete_form_submit', '0'),
('system_actions_delete_form', 'function', 'modules/system/system.module', 'system', 'actions_delete_form', '0'),
('system_actions_configure_submit', 'function', 'modules/system/system.module', 'system', 'actions_configure_submit', '0'),
('system_actions_configure_validate', 'function', 'modules/system/system.module', 'system', 'actions_configure_validate', '0'),
('system_actions_configure', 'function', 'modules/system/system.module', 'system', 'actions_configure', '0'),
('system_actions_manage_form_submit', 'function', 'modules/system/system.module', 'system', 'actions_manage_form_submit', '0'),
('system_actions_manage_form', 'function', 'modules/system/system.module', 'system', 'actions_manage_form', '0'),
('system_actions_manage', 'function', 'modules/system/system.module', 'system', 'actions_manage', '0'),
('system_action_info', 'function', 'modules/system/system.module', 'system', 'action_info', '0'),
('system_hook_info', 'function', 'modules/system/system.module', 'system', 'hook_info', '0'),
('system_cron', 'function', 'modules/system/system.module', 'system', 'cron', '0'),
('system_get_module_admin_tasks', 'function', 'modules/system/system.module', 'system', 'get_module_admin_tasks', '0'),
('system_admin_compact_page', 'function', 'modules/system/system.module', 'system', 'admin_compact_page', '0'),
('system_admin_compact_mode', 'function', 'modules/system/system.module', 'system', 'admin_compact_mode', '0'),
('confirm_form', 'function', 'modules/system/system.module', 'system', '', '0'),
('_system_sort_requirements', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_settings_form_submit', 'function', 'modules/system/system.module', 'system', 'settings_form_submit', '0'),
('system_settings_form', 'function', 'modules/system/system.module', 'system', 'settings_form', '0'),
('_system_settings_form_automatic_defaults', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_default_region', 'function', 'modules/system/system.module', 'system', 'default_region', '0'),
('system_region_list', 'function', 'modules/system/system.module', 'system', 'region_list', '0'),
('system_find_base_theme', 'function', 'modules/system/system.module', 'system', 'find_base_theme', '0'),
('system_get_theme_data', 'function', 'modules/system/system.module', 'system', 'get_theme_data', '0'),
('_system_get_theme_data', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_get_module_data', 'function', 'modules/system/system.module', 'system', 'get_module_data', '0'),
('_system_get_module_data', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_update_files_database', 'function', 'modules/system/system.module', 'system', 'update_files_database', '0'),
('system_get_files_database', 'function', 'modules/system/system.module', 'system', 'get_files_database', '0'),
('system_check_directory', 'function', 'modules/system/system.module', 'system', 'check_directory', '0'),
('system_theme_select_form', 'function', 'modules/system/system.module', 'system', 'theme_select_form', '0'),
('system_admin_menu_block', 'function', 'modules/system/system.module', 'system', 'admin_menu_block', '0'),
('system_block_view', 'function', 'modules/system/system.module', 'system', 'block_view', '0'),
('system_block_save', 'function', 'modules/system/system.module', 'system', 'block_save', '0'),
('system_block_configure', 'function', 'modules/system/system.module', 'system', 'block_configure', '0'),
('system_block_list', 'function', 'modules/system/system.module', 'system', 'block_list', '0'),
('system_user_timezone', 'function', 'modules/system/system.module', 'system', 'user_timezone', '0'),
('system_user_login', 'function', 'modules/system/system.module', 'system', 'user_login', '0'),
('system_user_register', 'function', 'modules/system/system.module', 'system', 'user_register', '0'),
('system_user_form', 'function', 'modules/system/system.module', 'system', 'user_form', '0'),
('system_preprocess_page', 'function', 'modules/system/system.module', 'system', 'preprocess_page', '0'),
('system_init', 'function', 'modules/system/system.module', 'system', 'init', '0'),
('system_filetransfer_backends', 'function', 'modules/system/system.module', 'system', 'filetransfer_backends', '0'),
('system_admin_menu_block_access', 'function', 'modules/system/system.module', 'system', 'admin_menu_block_access', '0'),
('_system_themes_access', 'function', 'modules/system/system.module', 'system', '', '0'),
('blocked_ip_load', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_menu', 'function', 'modules/system/system.module', 'system', 'menu', '0'),
('system_elements', 'function', 'modules/system/system.module', 'system', 'elements', '0'),
('system_rdf_namespaces', 'function', 'modules/system/system.module', 'system', 'rdf_namespaces', '0'),
('system_perm', 'function', 'modules/system/system.module', 'system', 'perm', '0'),
('system_theme', 'function', 'modules/system/system.module', 'system', 'theme', '0'),
('system_help', 'function', 'modules/system/system.module', 'system', 'help', '0'),
('system_main_admin_page', 'function', 'modules/system/system.admin.inc', 'system', 'main_admin_page', '0'),
('system_admin_menu_block_page', 'function', 'modules/system/system.admin.inc', 'system', 'admin_menu_block_page', '0'),
('system_admin_by_module', 'function', 'modules/system/system.admin.inc', 'system', 'admin_by_module', '0'),
('system_settings_overview', 'function', 'modules/system/system.admin.inc', 'system', 'settings_overview', '0'),
('system_themes_form', 'function', 'modules/system/system.admin.inc', 'system', 'themes_form', '0'),
('system_themes_form_submit', 'function', 'modules/system/system.admin.inc', 'system', 'themes_form_submit', '0'),
('system_theme_settings', 'function', 'modules/system/system.admin.inc', 'system', 'theme_settings', '0'),
('system_theme_settings_submit', 'function', 'modules/system/system.admin.inc', 'system', 'theme_settings_submit', '0'),
('_system_is_incompatible', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('system_modules', 'function', 'modules/system/system.admin.inc', 'system', 'modules', '0'),
('system_sort_modules_by_info_name', 'function', 'modules/system/system.admin.inc', 'system', 'sort_modules_by_info_name', '0'),
('_system_modules_build_row', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('system_modules_confirm_form', 'function', 'modules/system/system.admin.inc', 'system', 'modules_confirm_form', '0'),
('system_modules_submit', 'function', 'modules/system/system.admin.inc', 'system', 'modules_submit', '0'),
('system_modules_uninstall', 'function', 'modules/system/system.admin.inc', 'system', 'modules_uninstall', '0'),
('system_modules_uninstall_confirm_form', 'function', 'modules/system/system.admin.inc', 'system', 'modules_uninstall_confirm_form', '0'),
('system_modules_uninstall_validate', 'function', 'modules/system/system.admin.inc', 'system', 'modules_uninstall_validate', '0'),
('system_modules_uninstall_submit', 'function', 'modules/system/system.admin.inc', 'system', 'modules_uninstall_submit', '0'),
('system_ip_blocking', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking', '0'),
('system_ip_blocking_form', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking_form', '0'),
('system_ip_blocking_form_validate', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking_form_validate', '0'),
('system_ip_blocking_form_submit', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking_form_submit', '0'),
('system_ip_blocking_delete', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking_delete', '0'),
('system_ip_blocking_delete_submit', 'function', 'modules/system/system.admin.inc', 'system', 'ip_blocking_delete_submit', '0'),
('system_site_information_settings', 'function', 'modules/system/system.admin.inc', 'system', 'site_information_settings', '0'),
('system_site_information_settings_validate', 'function', 'modules/system/system.admin.inc', 'system', 'site_information_settings_validate', '0'),
('system_logging_settings', 'function', 'modules/system/system.admin.inc', 'system', 'logging_settings', '0'),
('system_performance_settings', 'function', 'modules/system/system.admin.inc', 'system', 'performance_settings', '0'),
('system_clear_cache_submit', 'function', 'modules/system/system.admin.inc', 'system', 'clear_cache_submit', '0'),
('system_file_system_settings', 'function', 'modules/system/system.admin.inc', 'system', 'file_system_settings', '0'),
('system_image_toolkit_settings', 'function', 'modules/system/system.admin.inc', 'system', 'image_toolkit_settings', '0'),
('system_rss_feeds_settings', 'function', 'modules/system/system.admin.inc', 'system', 'rss_feeds_settings', '0'),
('system_regional_settings', 'function', 'modules/system/system.admin.inc', 'system', 'regional_settings', '0'),
('system_regional_settings_submit', 'function', 'modules/system/system.admin.inc', 'system', 'regional_settings_submit', '0'),
('system_date_time_lookup', 'function', 'modules/system/system.admin.inc', 'system', 'date_time_lookup', '0'),
('system_site_maintenance_mode', 'function', 'modules/system/system.admin.inc', 'system', 'site_maintenance_mode', '0'),
('system_clean_url_settings', 'function', 'modules/system/system.admin.inc', 'system', 'clean_url_settings', '0'),
('system_status', 'function', 'modules/system/system.admin.inc', 'system', 'status', '0'),
('system_run_cron', 'function', 'modules/system/system.admin.inc', 'system', 'run_cron', '0'),
('system_php', 'function', 'modules/system/system.admin.inc', 'system', 'php', '0'),
('system_batch_page', 'function', 'modules/system/system.admin.inc', 'system', 'batch_page', '0'),
('theme_admin_block', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_admin_block_content', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_admin_page', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_admin_by_module', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_status_report', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_modules_fieldset', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_modules_incompatible', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_modules_uninstall', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_theme_select_form', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('theme_system_themes_form', 'function', 'modules/system/system.admin.inc', 'system', '', '0'),
('DrupalQueue', 'class', 'modules/system/system.queue.inc', 'system', '', '0'),
('DrupalQueueInterface', 'interface', 'modules/system/system.queue.inc', 'system', '', '0'),
('SystemQueue', 'class', 'modules/system/system.queue.inc', 'system', '', '0'),
('image_gd_settings', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_settings_validate', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_check_settings', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_resize', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_rotate', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_crop', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_desaturate', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_load', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_save', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('image_gd_create_tmp', 'function', 'modules/system/image.gd.inc', 'system', '', '0'),
('field_format', 'function', 'modules/field/field.module', 'field', 'format', '0'),
('_field_filter_xss_display_allowed_tags', 'function', 'modules/field/field.module', 'field', '', '0'),
('_field_filter_xss_allowed_tags', 'function', 'modules/field/field.module', 'field', '', '0'),
('menu_configure', 'function', 'modules/menu/menu.admin.inc', 'menu', 'configure', '0'),
('menu_reset_item_confirm_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'reset_item_confirm_submit', '0'),
('menu_reset_item_confirm', 'function', 'modules/menu/menu.admin.inc', 'menu', 'reset_item_confirm', '0'),
('menu_item_delete_form_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'item_delete_form_submit', '0'),
('node_modules_installed', 'function', 'modules/node/node.admin.inc', 'node', 'modules_installed', '0'),
('node_multiple_delete_confirm_submit', 'function', 'modules/node/node.admin.inc', 'node', 'multiple_delete_confirm_submit', '0'),
('node_multiple_delete_confirm', 'function', 'modules/node/node.admin.inc', 'node', 'multiple_delete_confirm', '0'),
('theme_node_admin_nodes', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('node_admin_nodes_submit', 'function', 'modules/node/node.admin.inc', 'node', 'admin_nodes_submit', '0'),
('node_admin_nodes_validate', 'function', 'modules/node/node.admin.inc', 'node', 'admin_nodes_validate', '0'),
('node_requirements', 'function', 'modules/node/node.module', 'node', 'requirements', '0'),
('theme_node_links', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_elements', 'function', 'modules/node/node.module', 'node', 'elements', '0'),
('node_list_permissions', 'function', 'modules/node/node.module', 'node', 'list_permissions', '0'),
('node_unpublish_by_keyword_action', 'function', 'modules/node/node.module', 'node', 'unpublish_by_keyword_action', '0'),
('node_unpublish_by_keyword_action_submit', 'function', 'modules/node/node.module', 'node', 'unpublish_by_keyword_action_submit', '0'),
('node_unpublish_by_keyword_action_form', 'function', 'modules/node/node.module', 'node', 'unpublish_by_keyword_action_form', '0'),
('node_assign_owner_action_submit', 'function', 'modules/node/node.module', 'node', 'assign_owner_action_submit', '0'),
('node_assign_owner_action_validate', 'function', 'modules/node/node.module', 'node', 'assign_owner_action_validate', '0'),
('node_assign_owner_action_form', 'function', 'modules/node/node.module', 'node', 'assign_owner_action_form', '0'),
('node_assign_owner_action', 'function', 'modules/node/node.module', 'node', 'assign_owner_action', '0'),
('node_save_action', 'function', 'modules/node/node.module', 'node', 'save_action', '0'),
('node_unpromote_action', 'function', 'modules/node/node.module', 'node', 'unpromote_action', '0'),
('node_promote_action', 'function', 'modules/node/node.module', 'node', 'promote_action', '0'),
('node_make_unsticky_action', 'function', 'modules/node/node.module', 'node', 'make_unsticky_action', '0'),
('node_make_sticky_action', 'function', 'modules/node/node.module', 'node', 'make_sticky_action', '0'),
('node_unpublish_action', 'function', 'modules/node/node.module', 'node', 'unpublish_action', '0'),
('node_publish_action', 'function', 'modules/node/node.module', 'node', 'publish_action', '0'),
('node_action_info', 'function', 'modules/node/node.module', 'node', 'action_info', '0'),
('node_hook_info', 'function', 'modules/node/node.module', 'node', 'hook_info', '0'),
('theme_node_submitted', 'function', 'modules/node/node.module', 'node', '', '0'),
('QueueTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('SystemThemeFunctionalTest', 'class', 'modules/system/system.test', 'system', '', '0'),
('SystemSettingsForm', 'class', 'modules/system/system.test', 'system', '', '0'),
('system_update_7028', 'function', 'modules/system/system.install', 'system', 'update_7028', '0'),
('system_update_7027', 'function', 'modules/system/system.install', 'system', 'update_7027', '0'),
('system_update_7026', 'function', 'modules/system/system.install', 'system', 'update_7026', '0'),
('system_update_7025', 'function', 'modules/system/system.install', 'system', 'update_7025', '0'),
('system_update_7024', 'function', 'modules/system/system.install', 'system', 'update_7024', '0'),
('system_update_7023', 'function', 'modules/system/system.install', 'system', 'update_7023', '0'),
('system_update_7022', 'function', 'modules/system/system.install', 'system', 'update_7022', '0'),
('system_update_7021', 'function', 'modules/system/system.install', 'system', 'update_7021', '0'),
('system_update_7020', 'function', 'modules/system/system.install', 'system', 'update_7020', '0'),
('system_update_7018', 'function', 'modules/system/system.install', 'system', 'update_7018', '0'),
('system_update_7017', 'function', 'modules/system/system.install', 'system', 'update_7017', '0'),
('system_update_7016', 'function', 'modules/system/system.install', 'system', 'update_7016', '0'),
('system_update_7015', 'function', 'modules/system/system.install', 'system', 'update_7015', '0'),
('system_update_7014', 'function', 'modules/system/system.install', 'system', 'update_7014', '0'),
('system_update_7013', 'function', 'modules/system/system.install', 'system', 'update_7013', '0'),
('system_update_7012', 'function', 'modules/system/system.install', 'system', 'update_7012', '0'),
('system_update_7011', 'function', 'modules/system/system.install', 'system', 'update_7011', '0'),
('system_update_7010', 'function', 'modules/system/system.install', 'system', 'update_7010', '0'),
('system_update_7009', 'function', 'modules/system/system.install', 'system', 'update_7009', '0'),
('system_update_7008', 'function', 'modules/system/system.install', 'system', 'update_7008', '0'),
('system_update_7007', 'function', 'modules/system/system.install', 'system', 'update_7007', '0'),
('system_update_7006', 'function', 'modules/system/system.install', 'system', 'update_7006', '0'),
('system_update_7005', 'function', 'modules/system/system.install', 'system', 'update_7005', '0'),
('system_update_7004', 'function', 'modules/system/system.install', 'system', 'update_7004', '0'),
('system_update_7003', 'function', 'modules/system/system.install', 'system', 'update_7003', '0'),
('system_update_7002', 'function', 'modules/system/system.install', 'system', 'update_7002', '0'),
('system_update_7001', 'function', 'modules/system/system.install', 'system', 'update_7001', '0'),
('system_update_7000', 'function', 'modules/system/system.install', 'system', 'update_7000', '0'),
('system_update_last_removed', 'function', 'modules/system/system.install', 'system', 'update_last_removed', '0'),
('system_schema', 'function', 'modules/system/system.install', 'system', 'schema', '0'),
('system_install', 'function', 'modules/system/system.install', 'system', 'install', '0'),
('system_requirements', 'function', 'modules/system/system.install', 'system', 'requirements', '0'),
('SystemBlockTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('FrontPageTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('PageTitleFiltering', 'class', 'modules/system/system.test', 'system', '', '0'),
('DateTimeFunctionalTest', 'class', 'modules/system/system.test', 'system', '', '0'),
('PageNotFoundTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('AccessDeniedTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('AdminMetaTagTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('AdminOverviewTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('CronRunTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('IPAddressBlockingTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('ModuleRequiredTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('ModuleDependencyTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('EnableDisableTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('ModuleTestCase', 'class', 'modules/system/system.test', 'system', '', '0'),
('Archive_Tar', 'class', 'modules/system/system.tar.inc', 'system', '', '0'),
('DatabaseStatement_sqlite', 'class', 'includes/database/sqlite/database.inc', '', '', '0'),
('DatabaseConnection_sqlite', 'class', 'includes/database/sqlite/database.inc', '', '', '0'),
('DatabaseInstaller_sqlite', 'class', 'includes/database/sqlite/install.inc', '', '', '0'),
('InsertQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', '', '0'),
('UpdateQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', '', '0'),
('DeleteQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', '', '0'),
('TruncateQuery_sqlite', 'class', 'includes/database/sqlite/query.inc', '', '', '0'),
('DatabaseSchema_sqlite', 'class', 'includes/database/sqlite/schema.inc', '', '', '0'),
('DatabaseConnection_pgsql', 'class', 'includes/database/pgsql/database.inc', '', '', '0'),
('DatabaseInstaller_pgsql', 'class', 'includes/database/pgsql/install.inc', '', '', '0'),
('InsertQuery_pgsql', 'class', 'includes/database/pgsql/query.inc', '', '', '0'),
('UpdateQuery_pgsql', 'class', 'includes/database/pgsql/query.inc', '', '', '0'),
('DatabaseSchema_pgsql', 'class', 'includes/database/pgsql/schema.inc', '', '', '0'),
('DatabaseConnection_mysql', 'class', 'includes/database/mysql/database.inc', '', '', '0'),
('DatabaseInstaller_mysql', 'class', 'includes/database/mysql/install.inc', '', '', '0'),
('InsertQuery_mysql', 'class', 'includes/database/mysql/query.inc', '', '', '0'),
('MergeQuery_mysql', 'class', 'includes/database/mysql/query.inc', '', '', '0'),
('DatabaseSchema_mysql', 'class', 'includes/database/mysql/schema.inc', '', '', '0'),
('db_add_unique_key', 'function', 'includes/database/database.inc', '', '', '0'),
('db_drop_primary_key', 'function', 'includes/database/database.inc', '', '', '0'),
('db_add_primary_key', 'function', 'includes/database/database.inc', '', '', '0'),
('db_field_set_no_default', 'function', 'includes/database/database.inc', '', '', '0'),
('db_field_set_default', 'function', 'includes/database/database.inc', '', '', '0'),
('db_drop_field', 'function', 'includes/database/database.inc', '', '', '0'),
('db_add_field', 'function', 'includes/database/database.inc', '', '', '0'),
('db_drop_table', 'function', 'includes/database/database.inc', '', '', '0'),
('db_rename_table', 'function', 'includes/database/database.inc', '', '', '0'),
('db_type_map', 'function', 'includes/database/database.inc', '', '', '0'),
('_db_create_keys_sql', 'function', 'includes/database/database.inc', '', '', '0'),
('db_type_placeholder', 'function', 'includes/database/database.inc', '', '', '0'),
('db_find_tables', 'function', 'includes/database/database.inc', '', '', '0'),
('db_column_exists', 'function', 'includes/database/database.inc', '', '', '0'),
('db_table_exists', 'function', 'includes/database/database.inc', '', '', '0'),
('db_field_names', 'function', 'includes/database/database.inc', '', '', '0'),
('db_create_table', 'function', 'includes/database/database.inc', '', '', '0'),
('db_driver', 'function', 'includes/database/database.inc', '', '', '0'),
('db_distinct_field', 'function', 'includes/database/database.inc', '', '', '0'),
('db_placeholders', 'function', 'includes/database/database.inc', '', '', '0'),
('update_sql', 'function', 'includes/database/database.inc', '', '', '0'),
('db_escape_table', 'function', 'includes/database/database.inc', '', '', '0'),
('db_is_active', 'function', 'includes/database/database.inc', '', '', '0'),
('db_set_active', 'function', 'includes/database/database.inc', '', '', '0'),
('db_transaction', 'function', 'includes/database/database.inc', '', '', '0'),
('db_select', 'function', 'includes/database/database.inc', '', '', '0'),
('db_truncate', 'function', 'includes/database/database.inc', '', '', '0'),
('db_delete', 'function', 'includes/database/database.inc', '', '', '0'),
('db_update', 'function', 'includes/database/database.inc', '', '', '0'),
('db_merge', 'function', 'includes/database/database.inc', '', '', '0'),
('db_insert', 'function', 'includes/database/database.inc', '', '', '0'),
('db_query_temporary', 'function', 'includes/database/database.inc', '', '', '0'),
('db_query_range', 'function', 'includes/database/database.inc', '', '', '0'),
('db_query', 'function', 'includes/database/database.inc', '', '', '0'),
('DatabaseStatementBase', 'class', 'includes/database/database.inc', '', '', '0'),
('DatabaseStatementInterface', 'interface', 'includes/database/database.inc', '', '', '0'),
('DatabaseTransaction', 'class', 'includes/database/database.inc', '', '', '0'),
('InvalidMergeQueryException', 'class', 'includes/database/database.inc', '', '', '0'),
('ExplicitTransactionsNotSupportedException', 'class', 'includes/database/database.inc', '', '', '0'),
('NoActiveTransactionException', 'class', 'includes/database/database.inc', '', '', '0'),
('TransactionsNotSupportedException', 'class', 'includes/database/database.inc', '', '', '0'),
('Database', 'class', 'includes/database/database.inc', '', '', '0'),
('DatabaseConnection', 'class', 'includes/database/database.inc', '', '', '0'),
('DatabaseLog', 'class', 'includes/database/log.inc', '', '', '0'),
('DatabaseStatementPrefetch', 'class', 'includes/database/prefetch.inc', '', '', '0'),
('DatabaseCondition', 'class', 'includes/database/query.inc', '', '', '0'),
('UpdateQuery', 'class', 'includes/database/query.inc', '', '', '0'),
('TruncateQuery', 'class', 'includes/database/query.inc', '', '', '0'),
('DeleteQuery', 'class', 'includes/database/query.inc', '', '', '0'),
('MergeQuery', 'class', 'includes/database/query.inc', '', '', '0'),
('InsertQuery', 'class', 'includes/database/query.inc', '', '', '0'),
('Query', 'class', 'includes/database/query.inc', '', '', '0'),
('QueryAlterableInterface', 'interface', 'includes/database/query.inc', '', '', '0'),
('QueryConditionInterface', 'interface', 'includes/database/query.inc', '', '', '0'),
('DatabaseSchema', 'class', 'includes/database/schema.inc', '', '', '0'),
('QueryExtendableInterface', 'interface', 'includes/database/select.inc', '', '', '0'),
('SelectQueryInterface', 'interface', 'includes/database/select.inc', '', '', '0'),
('SelectQueryExtender', 'class', 'includes/database/select.inc', '', '', '0'),
('SelectQuery', 'class', 'includes/database/select.inc', '', '', '0'),
('actions_do', 'function', 'includes/actions.inc', '', '', '0'),
('actions_list', 'function', 'includes/actions.inc', '', '', '0'),
('actions_get_all_actions', 'function', 'includes/actions.inc', '', '', '0'),
('actions_actions_map', 'function', 'includes/actions.inc', '', '', '0'),
('actions_function_lookup', 'function', 'includes/actions.inc', '', '', '0'),
('actions_synchronize', 'function', 'includes/actions.inc', '', '', '0'),
('actions_save', 'function', 'includes/actions.inc', '', '', '0'),
('actions_load', 'function', 'includes/actions.inc', '', '', '0'),
('actions_delete', 'function', 'includes/actions.inc', '', '', '0'),
('_batch_page', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_start', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_progress_page_js', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_do', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_progress_page_nojs', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_process', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_api_percentage', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_current_set', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_next_set', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_finished', 'function', 'includes/batch.inc', '', '', '0'),
('_batch_shutdown', 'function', 'includes/batch.inc', '', '', '0'),
('timer_start', 'function', 'includes/bootstrap.inc', '', '', '0'),
('timer_read', 'function', 'includes/bootstrap.inc', '', '', '0'),
('timer_stop', 'function', 'includes/bootstrap.inc', '', '', '0'),
('conf_path', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_initialize_variables', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_valid_http_host', 'function', 'includes/bootstrap.inc', '', '', '0'),
('conf_init', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_get_filename', 'function', 'includes/bootstrap.inc', '', '', '0'),
('variable_init', 'function', 'includes/bootstrap.inc', '', '', '0'),
('variable_get', 'function', 'includes/bootstrap.inc', '', '', '0'),
('variable_set', 'function', 'includes/bootstrap.inc', '', '', '0'),
('variable_del', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_page_get_cache', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_page_is_cacheable', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_load', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_set_header', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_get_header', 'function', 'includes/bootstrap.inc', '', '', '0'),
('_drupal_set_preferred_header_name', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_send_headers', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_page_header', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_serve_page_from_cache', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_unpack', 'function', 'includes/bootstrap.inc', '', '', '0'),
('check_plain', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_validate_utf8', 'function', 'includes/bootstrap.inc', '', '', '0'),
('request_uri', 'function', 'includes/bootstrap.inc', '', '', '0'),
('watchdog', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_set_message', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_get_messages', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_is_denied', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_anonymous_user', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_bootstrap', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_get_bootstrap_phase', 'function', 'includes/bootstrap.inc', '', '', '0'),
('_drupal_bootstrap', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_maintenance_theme', 'function', 'includes/bootstrap.inc', '', '', '0'),
('get_t', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_init_language', 'function', 'includes/bootstrap.inc', '', '', '0'),
('language_list', 'function', 'includes/bootstrap.inc', '', '', '0'),
('language_default', 'function', 'includes/bootstrap.inc', '', '', '0'),
('ip_address', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_get_schema', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_function_exists', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_autoload_interface', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_autoload_class', 'function', 'includes/bootstrap.inc', '', '', '0'),
('_registry_check_code', 'function', 'includes/bootstrap.inc', '', '', '0'),
('registry_rebuild', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_static', 'function', 'includes/bootstrap.inc', '', '', '0'),
('drupal_static_reset', 'function', 'includes/bootstrap.inc', '', '', '0'),
('cache_get', 'function', 'includes/cache.inc', '', '', '0'),
('cache_set', 'function', 'includes/cache.inc', '', '', '0'),
('cache_clear_all', 'function', 'includes/cache.inc', '', '', '0'),
('DrupalCacheInterface', 'interface', 'includes/cache.inc', '', '', '0'),
('cache_get_multiple', 'function', 'includes/cache.inc', '', '', '0'),
('_cache_get_object', 'function', 'includes/cache.inc', '', '', '0'),
('drupal_add_region_content', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_region_content', 'function', 'includes/common.inc', '', '', '0'),
('drupal_set_breadcrumb', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_breadcrumb', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_rdf_namespaces', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_html_head', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_html_head', 'function', 'includes/common.inc', '', '', '0'),
('drupal_clear_path_cache', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_feed', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_feeds', 'function', 'includes/common.inc', '', '', '0'),
('drupal_query_string_encode', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_destination', 'function', 'includes/common.inc', '', '', '0'),
('drupal_goto', 'function', 'includes/common.inc', '', '', '0'),
('drupal_site_offline', 'function', 'includes/common.inc', '', '', '0'),
('drupal_not_found', 'function', 'includes/common.inc', '', '', '0'),
('drupal_access_denied', 'function', 'includes/common.inc', '', '', '0'),
('drupal_http_request', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_error_handler', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_exception_handler', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_decode_exception', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_log_error', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_get_last_caller', 'function', 'includes/common.inc', '', '', '0'),
('_fix_gpc_magic', 'function', 'includes/common.inc', '', '', '0'),
('_fix_gpc_magic_files', 'function', 'includes/common.inc', '', '', '0'),
('fix_gpc_magic', 'function', 'includes/common.inc', '', '', '0'),
('t', 'function', 'includes/common.inc', '', '', '0'),
('valid_email_address', 'function', 'includes/common.inc', '', '', '0'),
('valid_url', 'function', 'includes/common.inc', '', '', '0'),
('flood_register_event', 'function', 'includes/common.inc', '', '', '0'),
('flood_is_allowed', 'function', 'includes/common.inc', '', '', '0'),
('check_file', 'function', 'includes/common.inc', '', '', '0'),
('check_url', 'function', 'includes/common.inc', '', '', '0'),
('filter_xss_admin', 'function', 'includes/common.inc', '', '', '0'),
('filter_xss', 'function', 'includes/common.inc', '', '', '0'),
('_filter_xss_split', 'function', 'includes/common.inc', '', '', '0'),
('_filter_xss_attributes', 'function', 'includes/common.inc', '', '', '0'),
('filter_xss_bad_protocol', 'function', 'includes/common.inc', '', '', '0'),
('format_rss_channel', 'function', 'includes/common.inc', '', '', '0'),
('format_rss_item', 'function', 'includes/common.inc', '', '', '0'),
('format_xml_elements', 'function', 'includes/common.inc', '', '', '0'),
('format_plural', 'function', 'includes/common.inc', '', '', '0'),
('parse_size', 'function', 'includes/common.inc', '', '', '0'),
('format_size', 'function', 'includes/common.inc', '', '', '0'),
('format_interval', 'function', 'includes/common.inc', '', '', '0'),
('format_date', 'function', 'includes/common.inc', '', '', '0'),
('url', 'function', 'includes/common.inc', '', '', '0'),
('drupal_attributes', 'function', 'includes/common.inc', '', '', '0'),
('l', 'function', 'includes/common.inc', '', '', '0'),
('drupal_page_footer', 'function', 'includes/common.inc', '', '', '0'),
('drupal_map_assoc', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_path', 'function', 'includes/common.inc', '', '', '0'),
('base_path', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_link', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_css', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_css', 'function', 'includes/common.inc', '', '', '0'),
('drupal_build_css_cache', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_build_css_path', 'function', 'includes/common.inc', '', '', '0'),
('drupal_load_stylesheet', 'function', 'includes/common.inc', '', '', '0'),
('drupal_load_stylesheet_content', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_load_stylesheet', 'function', 'includes/common.inc', '', '', '0'),
('drupal_clear_css_cache', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_js', 'function', 'includes/common.inc', '', '', '0'),
('drupal_js_defaults', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_js', 'function', 'includes/common.inc', '', '', '0'),
('drupal_add_tabledrag', 'function', 'includes/common.inc', '', '', '0'),
('drupal_build_js_cache', 'function', 'includes/common.inc', '', '', '0'),
('drupal_clear_js_cache', 'function', 'includes/common.inc', '', '', '0'),
('drupal_to_js', 'function', 'includes/common.inc', '', '', '0'),
('drupal_json', 'function', 'includes/common.inc', '', '', '0'),
('drupal_urlencode', 'function', 'includes/common.inc', '', '', '0'),
('drupal_random_bytes', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_private_key', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_token', 'function', 'includes/common.inc', '', '', '0'),
('drupal_valid_token', 'function', 'includes/common.inc', '', '', '0');
INSERT INTO `registry` VALUES
('_drupal_bootstrap_full', 'function', 'includes/common.inc', '', '', '0'),
('drupal_page_set_cache', 'function', 'includes/common.inc', '', '', '0'),
('drupal_cron_run', 'function', 'includes/common.inc', '', '', '0'),
('drupal_cron_cleanup', 'function', 'includes/common.inc', '', '', '0'),
('drupal_system_listing', 'function', 'includes/common.inc', '', '', '0'),
('drupal_alter', 'function', 'includes/common.inc', '', '', '0'),
('drupal_set_page_content', 'function', 'includes/common.inc', '', '', '0'),
('drupal_render_page', 'function', 'includes/common.inc', '', '', '0'),
('drupal_render', 'function', 'includes/common.inc', '', '', '0'),
('drupal_render_children', 'function', 'includes/common.inc', '', '', '0'),
('render', 'function', 'includes/common.inc', '', '', '0'),
('hide', 'function', 'includes/common.inc', '', '', '0'),
('show', 'function', 'includes/common.inc', '', '', '0'),
('element_sort', 'function', 'includes/common.inc', '', '', '0'),
('element_info', 'function', 'includes/common.inc', '', '', '0'),
('element_basic_defaults', 'function', 'includes/common.inc', '', '', '0'),
('drupal_sort_weight', 'function', 'includes/common.inc', '', '', '0'),
('element_property', 'function', 'includes/common.inc', '', '', '0'),
('element_properties', 'function', 'includes/common.inc', '', '', '0'),
('element_child', 'function', 'includes/common.inc', '', '', '0'),
('element_children', 'function', 'includes/common.inc', '', '', '0'),
('drupal_common_theme', 'function', 'includes/common.inc', '', '', '0'),
('drupal_install_schema', 'function', 'includes/common.inc', '', '', '0'),
('drupal_uninstall_schema', 'function', 'includes/common.inc', '', '', '0'),
('drupal_get_schema_unprocessed', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_initialize_schema', 'function', 'includes/common.inc', '', '', '0'),
('drupal_schema_fields_sql', 'function', 'includes/common.inc', '', '', '0'),
('drupal_write_record', 'function', 'includes/common.inc', '', '', '0'),
('drupal_parse_info_file', 'function', 'includes/common.inc', '', '', '0'),
('watchdog_severity_levels', 'function', 'includes/common.inc', '', '', '0'),
('drupal_explode_tags', 'function', 'includes/common.inc', '', '', '0'),
('drupal_implode_tags', 'function', 'includes/common.inc', '', '', '0'),
('drupal_flush_all_caches', 'function', 'includes/common.inc', '', '', '0'),
('_drupal_flush_css_js', 'function', 'includes/common.inc', '', '', '0'),
('file_create_url', 'function', 'includes/file.inc', '', '', '0'),
('file_create_path', 'function', 'includes/file.inc', '', '', '0'),
('file_check_directory', 'function', 'includes/file.inc', '', '', '0'),
('file_check_path', 'function', 'includes/file.inc', '', '', '0'),
('file_check_location', 'function', 'includes/file.inc', '', '', '0'),
('file_load_multiple', 'function', 'includes/file.inc', '', '', '0'),
('file_load', 'function', 'includes/file.inc', '', '', '0'),
('file_save', 'function', 'includes/file.inc', '', '', '0'),
('file_copy', 'function', 'includes/file.inc', '', '', '0'),
('file_unmanaged_copy', 'function', 'includes/file.inc', '', '', '0'),
('file_destination', 'function', 'includes/file.inc', '', '', '0'),
('file_move', 'function', 'includes/file.inc', '', '', '0'),
('file_unmanaged_move', 'function', 'includes/file.inc', '', '', '0'),
('file_munge_filename', 'function', 'includes/file.inc', '', '', '0'),
('file_unmunge_filename', 'function', 'includes/file.inc', '', '', '0'),
('file_create_filename', 'function', 'includes/file.inc', '', '', '0'),
('file_delete', 'function', 'includes/file.inc', '', '', '0'),
('file_unmanaged_delete', 'function', 'includes/file.inc', '', '', '0'),
('file_unmanaged_delete_recursive', 'function', 'includes/file.inc', '', '', '0'),
('file_space_used', 'function', 'includes/file.inc', '', '', '0'),
('file_save_upload', 'function', 'includes/file.inc', '', '', '0'),
('file_validate', 'function', 'includes/file.inc', '', '', '0'),
('file_validate_name_length', 'function', 'includes/file.inc', '', '', '0'),
('file_validate_extensions', 'function', 'includes/file.inc', '', '', '0'),
('file_validate_size', 'function', 'includes/file.inc', '', '', '0'),
('file_validate_is_image', 'function', 'includes/file.inc', '', '', '0'),
('file_validate_image_resolution', 'function', 'includes/file.inc', '', '', '0'),
('file_save_data', 'function', 'includes/file.inc', '', '', '0'),
('file_unmanaged_save_data', 'function', 'includes/file.inc', '', '', '0'),
('file_transfer', 'function', 'includes/file.inc', '', '', '0'),
('file_download', 'function', 'includes/file.inc', '', '', '0'),
('file_scan_directory', 'function', 'includes/file.inc', '', '', '0'),
('file_directory_temp', 'function', 'includes/file.inc', '', '', '0'),
('file_directory_path', 'function', 'includes/file.inc', '', '', '0'),
('file_upload_max_size', 'function', 'includes/file.inc', '', '', '0'),
('file_get_mimetype', 'function', 'includes/file.inc', '', '', '0'),
('drupal_chmod', 'function', 'includes/file.inc', '', '', '0'),
('file_default_mimetype_mapping', 'function', 'includes/file.mimetypes.inc', '', '', '0'),
('drupal_get_form', 'function', 'includes/form.inc', '', '', '0'),
('drupal_build_form', 'function', 'includes/form.inc', '', '', '0'),
('form_state_defaults', 'function', 'includes/form.inc', '', '', '0'),
('drupal_rebuild_form', 'function', 'includes/form.inc', '', '', '0'),
('form_get_cache', 'function', 'includes/form.inc', '', '', '0'),
('form_set_cache', 'function', 'includes/form.inc', '', '', '0'),
('drupal_form_submit', 'function', 'includes/form.inc', '', '', '0'),
('drupal_retrieve_form', 'function', 'includes/form.inc', '', '', '0'),
('drupal_process_form', 'function', 'includes/form.inc', '', '', '0'),
('drupal_prepare_form', 'function', 'includes/form.inc', '', '', '0'),
('drupal_validate_form', 'function', 'includes/form.inc', '', '', '0'),
('drupal_redirect_form', 'function', 'includes/form.inc', '', '', '0'),
('_form_validate', 'function', 'includes/form.inc', '', '', '0'),
('form_execute_handlers', 'function', 'includes/form.inc', '', '', '0'),
('form_set_error', 'function', 'includes/form.inc', '', '', '0'),
('form_clear_error', 'function', 'includes/form.inc', '', '', '0'),
('form_get_errors', 'function', 'includes/form.inc', '', '', '0'),
('form_get_error', 'function', 'includes/form.inc', '', '', '0'),
('form_error', 'function', 'includes/form.inc', '', '', '0'),
('form_builder', 'function', 'includes/form.inc', '', '', '0'),
('_form_builder_handle_input_element', 'function', 'includes/form.inc', '', '', '0'),
('_form_button_was_clicked', 'function', 'includes/form.inc', '', '', '0'),
('_form_builder_ie_cleanup', 'function', 'includes/form.inc', '', '', '0'),
('form_type_image_button_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_checkbox_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_checkboxes_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_password_confirm_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_select_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_textfield_value', 'function', 'includes/form.inc', '', '', '0'),
('form_type_token_value', 'function', 'includes/form.inc', '', '', '0'),
('form_set_value', 'function', 'includes/form.inc', '', '', '0'),
('_form_set_value', 'function', 'includes/form.inc', '', '', '0'),
('form_options_flatten', 'function', 'includes/form.inc', '', '', '0'),
('theme_select', 'function', 'includes/form.inc', '', '', '0'),
('form_select_options', 'function', 'includes/form.inc', '', '', '0'),
('form_get_options', 'function', 'includes/form.inc', '', '', '0'),
('theme_fieldset', 'function', 'includes/form.inc', '', '', '0'),
('theme_radio', 'function', 'includes/form.inc', '', '', '0'),
('theme_radios', 'function', 'includes/form.inc', '', '', '0'),
('form_process_password_confirm', 'function', 'includes/form.inc', '', '', '0'),
('password_confirm_validate', 'function', 'includes/form.inc', '', '', '0'),
('theme_date', 'function', 'includes/form.inc', '', '', '0'),
('form_process_date', 'function', 'includes/form.inc', '', '', '0'),
('date_validate', 'function', 'includes/form.inc', '', '', '0'),
('map_month', 'function', 'includes/form.inc', '', '', '0'),
('weight_value', 'function', 'includes/form.inc', '', '', '0'),
('form_ahah_callback', 'function', 'includes/form.inc', '', '', '0'),
('form_process_radios', 'function', 'includes/form.inc', '', '', '0'),
('form_process_text_format', 'function', 'includes/form.inc', '', '', '0'),
('theme_text_format_wrapper', 'function', 'includes/form.inc', '', '', '0'),
('form_process_ahah', 'function', 'includes/form.inc', '', '', '0'),
('theme_checkbox', 'function', 'includes/form.inc', '', '', '0'),
('theme_checkboxes', 'function', 'includes/form.inc', '', '', '0'),
('form_pre_render_conditional_form_element', 'function', 'includes/form.inc', '', '', '0'),
('form_process_checkboxes', 'function', 'includes/form.inc', '', '', '0'),
('theme_tableselect', 'function', 'includes/form.inc', '', '', '0'),
('form_process_tableselect', 'function', 'includes/form.inc', '', '', '0'),
('form_process_fieldset', 'function', 'includes/form.inc', '', '', '0'),
('form_pre_render_fieldset', 'function', 'includes/form.inc', '', '', '0'),
('form_process_vertical_tabs', 'function', 'includes/form.inc', '', '', '0'),
('theme_vertical_tabs', 'function', 'includes/form.inc', '', '', '0'),
('form_process_horizontal_tabs', 'function', 'includes/form.inc', '', '', '0'),
('form_expand_horizontal_tabs', 'function', 'includes/form.inc', '', '', '0'),
('_form_expand_horizontal_tabs', 'function', 'includes/form.inc', '', '', '0'),
('theme_horizontal_tabs', 'function', 'includes/form.inc', '', '', '0'),
('theme_submit', 'function', 'includes/form.inc', '', '', '0'),
('theme_button', 'function', 'includes/form.inc', '', '', '0'),
('theme_image_button', 'function', 'includes/form.inc', '', '', '0'),
('theme_hidden', 'function', 'includes/form.inc', '', '', '0'),
('theme_textfield', 'function', 'includes/form.inc', '', '', '0'),
('theme_form', 'function', 'includes/form.inc', '', '', '0'),
('theme_textarea', 'function', 'includes/form.inc', '', '', '0'),
('theme_markup', 'function', 'includes/form.inc', '', '', '0'),
('theme_password', 'function', 'includes/form.inc', '', '', '0'),
('form_process_weight', 'function', 'includes/form.inc', '', '', '0'),
('theme_file', 'function', 'includes/form.inc', '', '', '0'),
('theme_form_element', 'function', 'includes/form.inc', '', '', '0'),
('_form_set_class', 'function', 'includes/form.inc', '', '', '0'),
('form_clean_id', 'function', 'includes/form.inc', '', '', '0'),
('batch_set', 'function', 'includes/form.inc', '', '', '0'),
('batch_process', 'function', 'includes/form.inc', '', '', '0'),
('batch_get', 'function', 'includes/form.inc', '', '', '0'),
('drupal_depth_first_search', 'function', 'includes/graph.inc', '', '', '0'),
('_drupal_depth_first_search', 'function', 'includes/graph.inc', '', '', '0'),
('image_get_available_toolkits', 'function', 'includes/image.inc', '', '', '0'),
('image_get_toolkit', 'function', 'includes/image.inc', '', '', '0'),
('image_toolkit_invoke', 'function', 'includes/image.inc', '', '', '0'),
('image_get_info', 'function', 'includes/image.inc', '', '', '0'),
('image_scale_and_crop', 'function', 'includes/image.inc', '', '', '0'),
('image_scale', 'function', 'includes/image.inc', '', '', '0'),
('image_resize', 'function', 'includes/image.inc', '', '', '0'),
('image_rotate', 'function', 'includes/image.inc', '', '', '0'),
('image_crop', 'function', 'includes/image.inc', '', '', '0'),
('image_desaturate', 'function', 'includes/image.inc', '', '', '0'),
('image_load', 'function', 'includes/image.inc', '', '', '0'),
('image_save', 'function', 'includes/image.inc', '', '', '0'),
('drupal_verify_install_file', 'function', 'includes/install.inc', '', '', '0'),
('drupal_uninstall_modules', 'function', 'includes/install.inc', '', '', '0'),
('drupal_install_system', 'function', 'includes/install.inc', '', '', '0'),
('drupal_install_init_database', 'function', 'includes/install.inc', '', '', '0'),
('_drupal_install_module', 'function', 'includes/install.inc', '', '', '0'),
('drupal_install_modules', 'function', 'includes/install.inc', '', '', '0'),
('drupal_verify_profile', 'function', 'includes/install.inc', '', '', '0'),
('drupal_get_profile_modules', 'function', 'includes/install.inc', '', '', '0'),
('drupal_get_install_files', 'function', 'includes/install.inc', '', '', '0'),
('drupal_rewrite_settings', 'function', 'includes/install.inc', '', '', '0'),
('DatabaseInstaller', 'class', 'includes/install.inc', '', '', '0'),
('drupal_detect_database_types', 'function', 'includes/install.inc', '', '', '0'),
('drupal_detect_baseurl', 'function', 'includes/install.inc', '', '', '0'),
('drupal_install_profile_name', 'function', 'includes/install.inc', '', '', '0'),
('drupal_set_installed_schema_version', 'function', 'includes/install.inc', '', '', '0'),
('drupal_get_installed_schema_version', 'function', 'includes/install.inc', '', '', '0'),
('drupal_get_schema_versions', 'function', 'includes/install.inc', '', '', '0'),
('drupal_load_updates', 'function', 'includes/install.inc', '', '', '0'),
('_country_get_predefined_list', 'function', 'includes/iso.inc', '', '', '0'),
('_locale_get_predefined_list', 'function', 'includes/iso.inc', '', '', '0'),
('language_initialize', 'function', 'includes/language.inc', '', '', '0'),
('language_from_browser', 'function', 'includes/language.inc', '', '', '0'),
('language_url_rewrite', 'function', 'includes/language.inc', '', '', '0'),
('locale_languages_overview_form', 'function', 'includes/locale.inc', '', '', '0'),
('theme_locale_languages_overview_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_overview_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_add_screen', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_predefined_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_custom_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_edit_form', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_languages_common_controls', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_predefined_form_validate', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_predefined_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_edit_form_validate', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_edit_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_delete_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_delete_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_configure_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_languages_configure_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_overview_screen', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_seek_screen', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translation_filters', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translation_filter_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translation_filter_form_validate', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translation_filter_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_import_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_import_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_export_screen', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_export_po_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_export_pot_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_export_po_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_edit_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_string_is_safe', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_edit_form_validate', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_edit_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_delete_page', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_delete_form', 'function', 'includes/locale.inc', '', '', '0'),
('locale_translate_delete_form_submit', 'function', 'includes/locale.inc', '', '', '0'),
('locale_add_language', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_po', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_read_po', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_message', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_one_string', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_one_string_db', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_parse_header', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_parse_plural_forms', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_parse_arithmetic', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_tokenize_formula', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_append_plural', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_shorten_comments', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_import_parse_quoted', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_parse_js_file', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_get_strings', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_po_generate', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_po', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_string', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_wrap', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_export_remove_plural', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_translate_seek', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_translate_seek_query', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_invalidate_js', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_rebuild_js', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_translate_language_list', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_prepare_predefined_list', 'function', 'includes/locale.inc', '', '', '0'),
('locale_batch_by_language', 'function', 'includes/locale.inc', '', '', '0'),
('locale_batch_by_component', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_batch_build', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_batch_import', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_batch_system_finished', 'function', 'includes/locale.inc', '', '', '0'),
('_locale_batch_language_finished', 'function', 'includes/locale.inc', '', '', '0'),
('country_get_list', 'function', 'includes/locale.inc', '', '', '0'),
('drupal_mail', 'function', 'includes/mail.inc', '', '', '0'),
('drupal_mail_send', 'function', 'includes/mail.inc', '', '', '0'),
('drupal_wrap_mail', 'function', 'includes/mail.inc', '', '', '0'),
('drupal_html_to_text', 'function', 'includes/mail.inc', '', '', '0'),
('_drupal_wrap_mail_line', 'function', 'includes/mail.inc', '', '', '0'),
('_drupal_html_to_mail_urls', 'function', 'includes/mail.inc', '', '', '0'),
('_drupal_html_to_text_clean', 'function', 'includes/mail.inc', '', '', '0'),
('_drupal_html_to_text_pad', 'function', 'includes/mail.inc', '', '', '0'),
('menu_get_ancestors', 'function', 'includes/menu.inc', '', '', '0'),
('menu_unserialize', 'function', 'includes/menu.inc', '', '', '0'),
('menu_set_item', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_item', 'function', 'includes/menu.inc', '', '', '0'),
('menu_execute_active_handler', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_load_objects', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_check_access', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_item_localize', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_translate', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_link_map_translate', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tail_to_arg', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_link_translate', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_object', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_output', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_all_data', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_page_data', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_tree_cid', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_collect_node_links', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_check_access', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_tree_check_access', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tree_data', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_tree_data', 'function', 'includes/menu.inc', '', '', '0'),
('theme_menu_item_link', 'function', 'includes/menu.inc', '', '', '0'),
('theme_menu_tree', 'function', 'includes/menu.inc', '', '', '0'),
('theme_menu_item', 'function', 'includes/menu.inc', '', '', '0'),
('theme_menu_local_task', 'function', 'includes/menu.inc', '', '', '0'),
('drupal_help_arg', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_active_help', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_names', 'function', 'includes/menu.inc', '', '', '0'),
('menu_list_system_menus', 'function', 'includes/menu.inc', '', '', '0'),
('menu_main_menu', 'function', 'includes/menu.inc', '', '', '0'),
('menu_secondary_menu', 'function', 'includes/menu.inc', '', '', '0'),
('menu_navigation_links', 'function', 'includes/menu.inc', '', '', '0'),
('menu_local_tasks', 'function', 'includes/menu.inc', '', '', '0'),
('menu_primary_local_tasks', 'function', 'includes/menu.inc', '', '', '0'),
('menu_secondary_local_tasks', 'function', 'includes/menu.inc', '', '', '0'),
('menu_tab_root_path', 'function', 'includes/menu.inc', '', '', '0'),
('theme_menu_local_tasks', 'function', 'includes/menu.inc', '', '', '0'),
('menu_set_active_menu_names', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_active_menu_names', 'function', 'includes/menu.inc', '', '', '0'),
('menu_set_active_item', 'function', 'includes/menu.inc', '', '', '0'),
('menu_set_active_trail', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_active_trail', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_active_breadcrumb', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_active_title', 'function', 'includes/menu.inc', '', '', '0'),
('menu_link_load', 'function', 'includes/menu.inc', '', '', '0'),
('menu_cache_clear', 'function', 'includes/menu.inc', '', '', '0'),
('menu_cache_clear_all', 'function', 'includes/menu.inc', '', '', '0'),
('menu_rebuild', 'function', 'includes/menu.inc', '', '', '0'),
('menu_router_build', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_router_cache', 'function', 'includes/menu.inc', '', '', '0'),
('menu_get_router', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_link_build', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_navigation_links_rebuild', 'function', 'includes/menu.inc', '', '', '0'),
('menu_link_delete', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_delete_item', 'function', 'includes/menu.inc', '', '', '0'),
('menu_link_save', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_clear_page_cache', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_set_expanded_menus', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_find_router_path', 'function', 'includes/menu.inc', '', '', '0'),
('menu_link_maintain', 'function', 'includes/menu.inc', '', '', '0'),
('menu_link_children_relative_depth', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_link_move_children', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_update_parental_status', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_link_parents_set', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_router_build', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_router_save', 'function', 'includes/menu.inc', '', '', '0'),
('menu_path_is_external', 'function', 'includes/menu.inc', '', '', '0'),
('_menu_site_is_offline', 'function', 'includes/menu.inc', '', '', '0'),
('menu_valid_path', 'function', 'includes/menu.inc', '', '', '0'),
('module_implements', 'function', 'includes/module.inc', '', '', '0'),
('module_hook', 'function', 'includes/module.inc', '', '', '0'),
('module_disable', 'function', 'includes/module.inc', '', '', '0'),
('module_enable', 'function', 'includes/module.inc', '', '', '0'),
('module_load_all_includes', 'function', 'includes/module.inc', '', '', '0'),
('module_load_include', 'function', 'includes/module.inc', '', '', '0'),
('module_load_install', 'function', 'includes/module.inc', '', '', '0'),
('module_exists', 'function', 'includes/module.inc', '', '', '0'),
('_module_build_dependencies', 'function', 'includes/module.inc', '', '', '0'),
('module_list', 'function', 'includes/module.inc', '', '', '0'),
('module_load_all', 'function', 'includes/module.inc', '', '', '0'),
('PagerDefault', 'class', 'includes/pager.inc', '', '', '0'),
('pager_query', 'function', 'includes/pager.inc', '', '', '0'),
('pager_get_querystring', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager_first', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager_previous', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager_next', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager_last', 'function', 'includes/pager.inc', '', '', '0'),
('theme_pager_link', 'function', 'includes/pager.inc', '', '', '0'),
('pager_load_array', 'function', 'includes/pager.inc', '', '', '0'),
('_password_itoa64', 'function', 'includes/password.inc', '', '', '0'),
('_password_base64_encode', 'function', 'includes/password.inc', '', '', '0'),
('_password_generate_salt', 'function', 'includes/password.inc', '', '', '0'),
('_password_crypt', 'function', 'includes/password.inc', '', '', '0'),
('_password_get_count_log2', 'function', 'includes/password.inc', '', '', '0'),
('user_hash_password', 'function', 'includes/password.inc', '', '', '0'),
('user_check_password', 'function', 'includes/password.inc', '', '', '0'),
('user_needs_new_hash', 'function', 'includes/password.inc', '', '', '0'),
('drupal_init_path', 'function', 'includes/path.inc', '', '', '0'),
('drupal_lookup_path', 'function', 'includes/path.inc', '', '', '0'),
('drupal_cache_system_paths', 'function', 'includes/path.inc', '', '', '0'),
('drupal_get_path_alias', 'function', 'includes/path.inc', '', '', '0'),
('drupal_get_normal_path', 'function', 'includes/path.inc', '', '', '0'),
('arg', 'function', 'includes/path.inc', '', '', '0'),
('drupal_get_title', 'function', 'includes/path.inc', '', '', '0'),
('drupal_set_title', 'function', 'includes/path.inc', '', '', '0'),
('drupal_is_front_page', 'function', 'includes/path.inc', '', '', '0'),
('drupal_match_path', 'function', 'includes/path.inc', '', '', '0'),
('current_path', 'function', 'includes/path.inc', '', '', '0'),
('drupal_path_alias_whitelist_rebuild', 'function', 'includes/path.inc', '', '', '0'),
('_registry_rebuild', 'function', 'includes/registry.inc', '', '', '0'),
('registry_get_parsed_files', 'function', 'includes/registry.inc', '', '', '0'),
('_registry_parse_files', 'function', 'includes/registry.inc', '', '', '0'),
('_registry_parse_file', 'function', 'includes/registry.inc', '', '', '0'),
('_registry_get_resource_name', 'function', 'includes/registry.inc', '', '', '0'),
('_registry_skip_body', 'function', 'includes/registry.inc', '', '', '0'),
('_sess_open', 'function', 'includes/session.inc', '', '', '0'),
('_sess_close', 'function', 'includes/session.inc', '', '', '0'),
('_sess_read', 'function', 'includes/session.inc', '', '', '0'),
('_sess_write', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_initialize', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_start', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_commit', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_started', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_regenerate', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_count', 'function', 'includes/session.inc', '', '', '0'),
('_sess_destroy_sid', 'function', 'includes/session.inc', '', '', '0'),
('drupal_session_destroy_uid', 'function', 'includes/session.inc', '', '', '0'),
('_sess_gc', 'function', 'includes/session.inc', '', '', '0'),
('drupal_save_session', 'function', 'includes/session.inc', '', '', '0'),
('TableSort', 'class', 'includes/tablesort.inc', '', '', '0'),
('tablesort_init', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_sql', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_header', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_cell', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_get_querystring', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_get_order', 'function', 'includes/tablesort.inc', '', '', '0'),
('tablesort_get_sort', 'function', 'includes/tablesort.inc', '', '', '0'),
('init_theme', 'function', 'includes/theme.inc', '', '', '0'),
('_init_theme', 'function', 'includes/theme.inc', '', '', '0'),
('theme_get_registry', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_set_registry', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_load_registry', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_save_registry', 'function', 'includes/theme.inc', '', '', '0'),
('drupal_theme_rebuild', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_process_registry', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_build_registry', 'function', 'includes/theme.inc', '', '', '0'),
('list_themes', 'function', 'includes/theme.inc', '', '', '0'),
('theme', 'function', 'includes/theme.inc', '', '', '0'),
('drupal_discover_template', 'function', 'includes/theme.inc', '', '', '0'),
('path_to_theme', 'function', 'includes/theme.inc', '', '', '0'),
('drupal_find_theme_functions', 'function', 'includes/theme.inc', '', '', '0'),
('drupal_find_theme_templates', 'function', 'includes/theme.inc', '', '', '0'),
('theme_get_settings', 'function', 'includes/theme.inc', '', '', '0'),
('theme_get_setting', 'function', 'includes/theme.inc', '', '', '0'),
('theme_render_template', 'function', 'includes/theme.inc', '', '', '0'),
('theme_placeholder', 'function', 'includes/theme.inc', '', '', '0'),
('theme_status_messages', 'function', 'includes/theme.inc', '', '', '0'),
('theme_links', 'function', 'includes/theme.inc', '', '', '0'),
('theme_image', 'function', 'includes/theme.inc', '', '', '0'),
('theme_breadcrumb', 'function', 'includes/theme.inc', '', '', '0'),
('theme_submenu', 'function', 'includes/theme.inc', '', '', '0'),
('theme_table', 'function', 'includes/theme.inc', '', '', '0'),
('theme_table_select_header_cell', 'function', 'includes/theme.inc', '', '', '0'),
('theme_tablesort_indicator', 'function', 'includes/theme.inc', '', '', '0'),
('theme_mark', 'function', 'includes/theme.inc', '', '', '0'),
('theme_item_list', 'function', 'includes/theme.inc', '', '', '0'),
('theme_list', 'function', 'includes/theme.inc', '', '', '0'),
('theme_more_help_link', 'function', 'includes/theme.inc', '', '', '0'),
('theme_feed_icon', 'function', 'includes/theme.inc', '', '', '0'),
('theme_more_link', 'function', 'includes/theme.inc', '', '', '0'),
('theme_closure', 'function', 'includes/theme.inc', '', '', '0'),
('theme_username', 'function', 'includes/theme.inc', '', '', '0'),
('theme_progress_bar', 'function', 'includes/theme.inc', '', '', '0'),
('theme_indentation', 'function', 'includes/theme.inc', '', '', '0'),
('_theme_table_cell', 'function', 'includes/theme.inc', '', '', '0'),
('template_preprocess', 'function', 'includes/theme.inc', '', '', '0'),
('template_process', 'function', 'includes/theme.inc', '', '', '0'),
('template_preprocess_page', 'function', 'includes/theme.inc', '', '', '0'),
('template_process_page', 'function', 'includes/theme.inc', '', '', '0'),
('template_page_suggestions', 'function', 'includes/theme.inc', '', '', '0'),
('_drupal_maintenance_theme', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('_theme_load_offline_registry', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('theme_task_list', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('theme_install_page', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('theme_update_page', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('template_preprocess_maintenance_page', 'function', 'includes/theme.maintenance.inc', '', '', '0'),
('unicode_check', 'function', 'includes/unicode.inc', '', '', '0'),
('_unicode_check', 'function', 'includes/unicode.inc', '', '', '0'),
('unicode_requirements', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_xml_parser_create', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_convert_to_utf8', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_truncate_bytes', 'function', 'includes/unicode.inc', '', '', '0'),
('truncate_utf8', 'function', 'includes/unicode.inc', '', '', '0'),
('mime_header_encode', 'function', 'includes/unicode.inc', '', '', '0'),
('mime_header_decode', 'function', 'includes/unicode.inc', '', '', '0'),
('_mime_header_decode', 'function', 'includes/unicode.inc', '', '', '0'),
('decode_entities', 'function', 'includes/unicode.inc', '', '', '0'),
('_decode_entities', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_strlen', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_strtoupper', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_strtolower', 'function', 'includes/unicode.inc', '', '', '0'),
('_unicode_caseflip', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_ucfirst', 'function', 'includes/unicode.inc', '', '', '0'),
('drupal_substr', 'function', 'includes/unicode.inc', '', '', '0'),
('xmlrpc_value', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_value_calculate_type', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_value_get_xml', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_parse', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_set', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_get', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_tag_open', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_cdata', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_message_tag_close', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_request', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_error', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_error_get_xml', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_date', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_date_get_xml', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_base64', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_base64_get_xml', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_errno', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_error_msg', 'function', 'includes/xmlrpc.inc', '', '', '0'),
('xmlrpc_server', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_error', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_output', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_set', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_get', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_call', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_multicall', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_list_methods', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_get_capabilities', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_method_signature', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('xmlrpc_server_method_help', 'function', 'includes/xmlrpcs.inc', '', '', '0'),
('node_forms', 'function', 'modules/node/node.module', 'node', 'forms', '0'),
('node_content_form', 'function', 'modules/node/node.module', 'node', 'content_form', '0'),
('node_content_access', 'function', 'modules/node/node.module', 'node', 'content_access', '0'),
('_node_access_rebuild_batch_finished', 'function', 'modules/node/node.module', 'node', '', '0'),
('_node_access_rebuild_batch_operation', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_access_rebuild', 'function', 'modules/node/node.module', 'node', 'access_rebuild', '0'),
('node_access_needs_rebuild', 'function', 'modules/node/node.module', 'node', 'access_needs_rebuild', '0'),
('node_access_write_grants', 'function', 'modules/node/node.module', 'node', 'access_write_grants', '0'),
('node_access_acquire_grants', 'function', 'modules/node/node.module', 'node', 'access_acquire_grants', '0'),
('node_query_node_access_alter', 'function', 'modules/node/node.module', 'node', 'query_node_access_alter', '0'),
('node_db_rewrite_sql', 'function', 'modules/node/node.module', 'node', 'db_rewrite_sql', '0'),
('node_access_view_all_nodes', 'function', 'modules/node/node.module', 'node', 'access_view_all_nodes', '0'),
('node_access_grants', 'function', 'modules/node/node.module', 'node', 'access_grants', '0'),
('_node_access_where_sql', 'function', 'modules/node/node.module', 'node', '', '0'),
('_node_access_join_sql', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_access', 'function', 'modules/node/node.module', 'node', 'access', '0'),
('node_search_validate', 'function', 'modules/node/node.module', 'node', 'search_validate', '0'),
('node_form_search_form_alter', 'function', 'modules/node/node.module', 'node', 'form_search_form_alter', '0'),
('_node_index_node', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_update_index', 'function', 'modules/node/node.module', 'node', 'update_index', '0'),
('node_page_view', 'function', 'modules/node/node.module', 'node', 'page_view', '0'),
('node_page_default', 'function', 'modules/node/node.module', 'node', 'page_default', '0'),
('node_build_multiple', 'function', 'modules/node/node.module', 'node', 'build_multiple', '0'),
('node_feed', 'function', 'modules/node/node.module', 'node', 'feed', '0'),
('node_block_view', 'function', 'modules/node/node.module', 'node', 'block_view', '0'),
('node_block_list', 'function', 'modules/node/node.module', 'node', 'block_list', '0'),
('node_revision_list', 'function', 'modules/node/node.module', 'node', 'revision_list', '0'),
('node_last_changed', 'function', 'modules/node/node.module', 'node', 'last_changed', '0'),
('node_init', 'function', 'modules/node/node.module', 'node', 'init', '0'),
('node_page_title', 'function', 'modules/node/node.module', 'node', 'page_title', '0'),
('node_menu', 'function', 'modules/node/node.module', 'node', 'menu', '0'),
('_node_add_access', 'function', 'modules/node/node.module', 'node', '', '0'),
('_node_revision_access', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_link', 'function', 'modules/node/node.module', 'node', 'link', '0'),
('theme_node_search_admin', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_user_cancel', 'function', 'modules/node/node.module', 'node', 'user_cancel', '0'),
('node_ranking', 'function', 'modules/node/node.module', 'node', 'ranking', '0'),
('node_search', 'function', 'modules/node/node.module', 'node', 'search', '0'),
('_node_rankings', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_perm', 'function', 'modules/node/node.module', 'node', 'perm', '0'),
('theme_node_log_message', 'function', 'modules/node/node.module', 'node', '', '0'),
('template_preprocess_node', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_show', 'function', 'modules/node/node.module', 'node', 'show', '0'),
('node_build_content', 'function', 'modules/node/node.module', 'node', 'build_content', '0'),
('node_build', 'function', 'modules/node/node.module', 'node', 'build', '0'),
('node_delete_multiple', 'function', 'modules/node/node.module', 'node', 'delete_multiple', '0'),
('node_delete', 'function', 'modules/node/node.module', 'node', 'delete', '0'),
('_node_save_revision', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_save', 'function', 'modules/node/node.module', 'node', 'save', '0'),
('node_submit', 'function', 'modules/node/node.module', 'node', 'submit', '0'),
('node_validate', 'function', 'modules/node/node.module', 'node', 'validate', '0'),
('node_load', 'function', 'modules/node/node.module', 'node', 'load', '0'),
('node_load_multiple', 'function', 'modules/node/node.module', 'node', 'load_multiple', '0'),
('node_invoke', 'function', 'modules/node/node.module', 'node', 'invoke', '0'),
('node_hook', 'function', 'modules/node/node.module', 'node', 'hook', '0'),
('node_type_set_defaults', 'function', 'modules/node/node.module', 'node', 'type_set_defaults', '0'),
('_node_types_build', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_type_update_nodes', 'function', 'modules/node/node.module', 'node', 'type_update_nodes', '0'),
('node_type_delete', 'function', 'modules/node/node.module', 'node', 'type_delete', '0'),
('node_configure_fields', 'function', 'modules/node/node.module', 'node', 'configure_fields', '0'),
('node_type_save', 'function', 'modules/node/node.module', 'node', 'type_save', '0'),
('node_types_rebuild', 'function', 'modules/node/node.module', 'node', 'types_rebuild', '0'),
('node_type_get_name', 'function', 'modules/node/node.module', 'node', 'type_get_name', '0'),
('node_type_get_names', 'function', 'modules/node/node.module', 'node', 'type_get_names', '0'),
('node_type_get_base', 'function', 'modules/node/node.module', 'node', 'type_get_base', '0'),
('node_type_get_type', 'function', 'modules/node/node.module', 'node', 'type_get_type', '0'),
('node_type_get_types', 'function', 'modules/node/node.module', 'node', 'type_get_types', '0'),
('node_type_clear', 'function', 'modules/node/node.module', 'node', 'type_clear', '0'),
('node_mark', 'function', 'modules/node/node.module', 'node', 'mark', '0'),
('_node_extract_type', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_last_viewed', 'function', 'modules/node/node.module', 'node', 'last_viewed', '0'),
('node_tag_new', 'function', 'modules/node/node.module', 'node', 'tag_new', '0'),
('node_title_list', 'function', 'modules/node/node.module', 'node', 'title_list', '0'),
('theme_node_list', 'function', 'modules/node/node.module', 'node', '', '0'),
('node_field_build_modes', 'function', 'modules/node/node.module', 'node', 'field_build_modes', '0'),
('node_fieldable_info', 'function', 'modules/node/node.module', 'node', 'fieldable_info', '0'),
('node_cron', 'function', 'modules/node/node.module', 'node', 'cron', '0'),
('node_theme', 'function', 'modules/node/node.module', 'node', 'theme', '0'),
('node_help', 'function', 'modules/node/node.module', 'node', 'help', '0'),
('node_overview_types', 'function', 'modules/node/content_types.inc', 'node', 'overview_types', '0'),
('theme_node_admin_overview', 'function', 'modules/node/content_types.inc', 'node', '', '0'),
('node_type_form', 'function', 'modules/node/content_types.inc', 'node', 'type_form', '0'),
('_node_characters', 'function', 'modules/node/content_types.inc', 'node', '', '0'),
('node_type_form_validate', 'function', 'modules/node/content_types.inc', 'node', 'type_form_validate', '0'),
('node_type_form_submit', 'function', 'modules/node/content_types.inc', 'node', 'type_form_submit', '0'),
('node_node_type', 'function', 'modules/node/content_types.inc', 'node', 'node_type', '0'),
('node_type_reset', 'function', 'modules/node/content_types.inc', 'node', 'type_reset', '0'),
('node_type_delete_confirm', 'function', 'modules/node/content_types.inc', 'node', 'type_delete_confirm', '0'),
('node_type_delete_confirm_submit', 'function', 'modules/node/content_types.inc', 'node', 'type_delete_confirm_submit', '0'),
('node_admin_nodes', 'function', 'modules/node/node.admin.inc', 'node', 'admin_nodes', '0'),
('node_admin_content', 'function', 'modules/node/node.admin.inc', 'node', 'admin_content', '0'),
('_node_mass_update_batch_finished', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('_node_mass_update_batch_process', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('_node_mass_update_helper', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('node_mass_update', 'function', 'modules/node/node.admin.inc', 'node', 'mass_update', '0'),
('node_filter_form_submit', 'function', 'modules/node/node.admin.inc', 'node', 'filter_form_submit', '0'),
('theme_node_filters', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('theme_node_filter_form', 'function', 'modules/node/node.admin.inc', 'node', '', '0'),
('node_filter_form', 'function', 'modules/node/node.admin.inc', 'node', 'filter_form', '0'),
('node_build_filter_query', 'function', 'modules/node/node.admin.inc', 'node', 'build_filter_query', '0'),
('node_filters', 'function', 'modules/node/node.admin.inc', 'node', 'filters', '0'),
('node_node_operations', 'function', 'modules/node/node.admin.inc', 'node', 'node_operations', '0'),
('node_configure_rebuild_confirm_submit', 'function', 'modules/node/node.admin.inc', 'node', 'configure_rebuild_confirm_submit', '0'),
('node_configure_rebuild_confirm', 'function', 'modules/node/node.admin.inc', 'node', 'configure_rebuild_confirm', '0'),
('node_configure_access_submit', 'function', 'modules/node/node.admin.inc', 'node', 'configure_access_submit', '0'),
('node_configure', 'function', 'modules/node/node.admin.inc', 'node', 'configure', '0'),
('node_page_edit', 'function', 'modules/node/node.pages.inc', 'node', 'page_edit', '0'),
('node_add_page', 'function', 'modules/node/node.pages.inc', 'node', 'add_page', '0'),
('theme_node_add_list', 'function', 'modules/node/node.pages.inc', 'node', '', '0'),
('node_add', 'function', 'modules/node/node.pages.inc', 'node', 'add', '0'),
('node_form_validate', 'function', 'modules/node/node.pages.inc', 'node', 'form_validate', '0'),
('node_object_prepare', 'function', 'modules/node/node.pages.inc', 'node', 'object_prepare', '0'),
('node_form', 'function', 'modules/node/node.pages.inc', 'node', 'form', '0'),
('node_form_delete_submit', 'function', 'modules/node/node.pages.inc', 'node', 'form_delete_submit', '0'),
('node_form_build_preview', 'function', 'modules/node/node.pages.inc', 'node', 'form_build_preview', '0'),
('theme_node_form', 'function', 'modules/node/node.pages.inc', 'node', '', '0'),
('node_preview', 'function', 'modules/node/node.pages.inc', 'node', 'preview', '0'),
('theme_node_preview', 'function', 'modules/node/node.pages.inc', 'node', '', '0'),
('node_form_submit', 'function', 'modules/node/node.pages.inc', 'node', 'form_submit', '0'),
('node_form_submit_build_node', 'function', 'modules/node/node.pages.inc', 'node', 'form_submit_build_node', '0'),
('node_delete_confirm', 'function', 'modules/node/node.pages.inc', 'node', 'delete_confirm', '0'),
('node_delete_confirm_submit', 'function', 'modules/node/node.pages.inc', 'node', 'delete_confirm_submit', '0'),
('node_form_js', 'function', 'modules/node/node.pages.inc', 'node', 'form_js', '0'),
('node_revision_overview', 'function', 'modules/node/node.pages.inc', 'node', 'revision_overview', '0'),
('node_revision_revert_confirm', 'function', 'modules/node/node.pages.inc', 'node', 'revision_revert_confirm', '0'),
('node_revision_revert_confirm_submit', 'function', 'modules/node/node.pages.inc', 'node', 'revision_revert_confirm_submit', '0'),
('node_revision_delete_confirm', 'function', 'modules/node/node.pages.inc', 'node', 'revision_delete_confirm', '0'),
('node_revision_delete_confirm_submit', 'function', 'modules/node/node.pages.inc', 'node', 'revision_delete_confirm_submit', '0'),
('node_schema', 'function', 'modules/node/node.install', 'node', 'schema', '0'),
('node_update_7000', 'function', 'modules/node/node.install', 'node', 'update_7000', '0'),
('node_update_7001', 'function', 'modules/node/node.install', 'node', 'update_7001', '0'),
('node_update_7002', 'function', 'modules/node/node.install', 'node', 'update_7002', '0'),
('node_update_7003', 'function', 'modules/node/node.install', 'node', 'update_7003', '0'),
('node_update_7004', 'function', 'modules/node/node.install', 'node', 'update_7004', '0'),
('node_update_7005', 'function', 'modules/node/node.install', 'node', 'update_7005', '0'),
('NodeLoadMultipleUnitTest', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeRevisionsTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('PageEditTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('PagePreviewTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('PageCreationTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('PageViewTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeTitleXSSTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeBlockTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodePostSettingsTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeRSSContentTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeAccessRecordsAlterUnitTest', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeSaveTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeTypeTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('NodeAccessRebuildTestCase', 'class', 'modules/node/node.test', 'node', '', '0'),
('filter_help', 'function', 'modules/filter/filter.module', 'filter', 'help', '0'),
('filter_theme', 'function', 'modules/filter/filter.module', 'filter', 'theme', '0'),
('filter_menu', 'function', 'modules/filter/filter.module', 'filter', 'menu', '0'),
('filter_format_load', 'function', 'modules/filter/filter.module', 'filter', 'format_load', '0'),
('filter_admin_format_title', 'function', 'modules/filter/filter.module', 'filter', 'admin_format_title', '0'),
('filter_perm', 'function', 'modules/filter/filter.module', 'filter', 'perm', '0'),
('filter_cron', 'function', 'modules/filter/filter.module', 'filter', 'cron', '0');
INSERT INTO `registry` VALUES
('filter_filter_tips', 'function', 'modules/filter/filter.module', 'filter', 'filter_tips', '0'),
('filter_formats', 'function', 'modules/filter/filter.module', 'filter', 'formats', '0'),
('filter_list_all', 'function', 'modules/filter/filter.module', 'filter', 'list_all', '0'),
('_filter_list_cmp', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('filter_resolve_format', 'function', 'modules/filter/filter.module', 'filter', 'resolve_format', '0'),
('filter_format_allowcache', 'function', 'modules/filter/filter.module', 'filter', 'format_allowcache', '0'),
('filter_list_format', 'function', 'modules/filter/filter.module', 'filter', 'list_format', '0'),
('check_markup', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('filter_form', 'function', 'modules/filter/filter.module', 'filter', 'form', '0'),
('filter_access', 'function', 'modules/filter/filter.module', 'filter', 'access', '0'),
('_filter_tips', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('theme_filter_tips_more_info', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('theme_filter_guidelines', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('filter_filter', 'function', 'modules/filter/filter.module', 'filter', 'filter', '0'),
('_filter_html_settings', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_html', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_url_settings', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_url', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_htmlcorrector', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_url_parse_full_links', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_url_parse_partial_links', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_url_trim', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('_filter_autop', 'function', 'modules/filter/filter.module', 'filter', '', '0'),
('filter_admin_overview', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_overview', '0'),
('filter_admin_overview_submit', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_overview_submit', '0'),
('theme_filter_admin_overview', 'function', 'modules/filter/filter.admin.inc', 'filter', '', '0'),
('filter_admin_format_page', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_format_page', '0'),
('filter_admin_format_form', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_format_form', '0'),
('filter_admin_format_form_validate', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_format_form_validate', '0'),
('filter_admin_format_form_submit', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_format_form_submit', '0'),
('filter_admin_delete', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_delete', '0'),
('filter_admin_delete_submit', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_delete_submit', '0'),
('filter_admin_configure_page', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_configure_page', '0'),
('filter_admin_configure', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_configure', '0'),
('filter_admin_configure_submit', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_configure_submit', '0'),
('filter_admin_order_page', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_order_page', '0'),
('filter_admin_order', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_order', '0'),
('theme_filter_admin_order', 'function', 'modules/filter/filter.admin.inc', 'filter', '', '0'),
('filter_admin_order_submit', 'function', 'modules/filter/filter.admin.inc', 'filter', 'admin_order_submit', '0'),
('filter_tips_long', 'function', 'modules/filter/filter.pages.inc', 'filter', 'tips_long', '0'),
('theme_filter_tips', 'function', 'modules/filter/filter.pages.inc', 'filter', '', '0'),
('filter_schema', 'function', 'modules/filter/filter.install', 'filter', 'schema', '0'),
('filter_update_7000', 'function', 'modules/filter/filter.install', 'filter', 'update_7000', '0'),
('filter_update_7001', 'function', 'modules/filter/filter.install', 'filter', 'update_7001', '0'),
('filter_update_7002', 'function', 'modules/filter/filter.install', 'filter', 'update_7002', '0'),
('FilterAdminTestCase', 'class', 'modules/filter/filter.test', 'filter', '', '0'),
('FilterTestCase', 'class', 'modules/filter/filter.test', 'filter', '', '0'),
('text_theme', 'function', 'modules/field/modules/text/text.module', 'text', 'theme', '0'),
('text_field_info', 'function', 'modules/field/modules/text/text.module', 'text', 'field_info', '0'),
('text_field_schema', 'function', 'modules/field/modules/text/text.module', 'text', 'field_schema', '0'),
('text_field_validate', 'function', 'modules/field/modules/text/text.module', 'text', 'field_validate', '0'),
('text_field_load', 'function', 'modules/field/modules/text/text.module', 'text', 'field_load', '0'),
('text_field_sanitize', 'function', 'modules/field/modules/text/text.module', 'text', 'field_sanitize', '0'),
('text_field_is_empty', 'function', 'modules/field/modules/text/text.module', 'text', 'field_is_empty', '0'),
('text_field_formatter_info', 'function', 'modules/field/modules/text/text.module', 'text', 'field_formatter_info', '0'),
('theme_field_formatter_text_default', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('theme_field_formatter_text_plain', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('theme_field_formatter_text_trimmed', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('theme_field_formatter_text_summary_or_trimmed', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('text_summary', 'function', 'modules/field/modules/text/text.module', 'text', 'summary', '0'),
('text_field_widget_info', 'function', 'modules/field/modules/text/text.module', 'text', 'field_widget_info', '0'),
('text_elements', 'function', 'modules/field/modules/text/text.module', 'text', 'elements', '0'),
('text_field_widget', 'function', 'modules/field/modules/text/text.module', 'text', 'field_widget', '0'),
('text_field_widget_error', 'function', 'modules/field/modules/text/text.module', 'text', 'field_widget_error', '0'),
('text_textfield_elements_process', 'function', 'modules/field/modules/text/text.module', 'text', 'textfield_elements_process', '0'),
('text_textarea_elements_process', 'function', 'modules/field/modules/text/text.module', 'text', 'textarea_elements_process', '0'),
('text_textarea_with_summary_process', 'function', 'modules/field/modules/text/text.module', 'text', 'textarea_with_summary_process', '0'),
('text_field_widget_formatted_text_value', 'function', 'modules/field/modules/text/text.module', 'text', 'field_widget_formatted_text_value', '0'),
('theme_text_textfield', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('theme_text_textarea', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('theme_text_textarea_with_summary', 'function', 'modules/field/modules/text/text.module', 'text', '', '0'),
('TextFieldTestCase', 'class', 'modules/field/modules/text/text.test', 'text', '', '0'),
('TextSummaryTestCase', 'class', 'modules/field/modules/text/text.test', 'text', '', '0'),
('options_theme', 'function', 'modules/field/modules/options/options.module', 'options', 'theme', '0'),
('options_field_widget_info', 'function', 'modules/field/modules/options/options.module', 'options', 'field_widget_info', '0'),
('options_elements', 'function', 'modules/field/modules/options/options.module', 'options', 'elements', '0'),
('options_field_widget', 'function', 'modules/field/modules/options/options.module', 'options', 'field_widget', '0'),
('options_field_widget_error', 'function', 'modules/field/modules/options/options.module', 'options', 'field_widget_error', '0'),
('options_buttons_elements_process', 'function', 'modules/field/modules/options/options.module', 'options', 'buttons_elements_process', '0'),
('options_select_elements_process', 'function', 'modules/field/modules/options/options.module', 'options', 'select_elements_process', '0'),
('options_onoff_elements_process', 'function', 'modules/field/modules/options/options.module', 'options', 'onoff_elements_process', '0'),
('options_validate', 'function', 'modules/field/modules/options/options.module', 'options', 'validate', '0'),
('options_data2form', 'function', 'modules/field/modules/options/options.module', 'options', 'data2form', '0'),
('options_form2data', 'function', 'modules/field/modules/options/options.module', 'options', 'form2data', '0'),
('options_transpose_array_rows_cols', 'function', 'modules/field/modules/options/options.module', 'options', 'transpose_array_rows_cols', '0'),
('options_options', 'function', 'modules/field/modules/options/options.module', 'options', 'options', '0'),
('theme_options_none', 'function', 'modules/field/modules/options/options.module', 'options', '', '0'),
('theme_options_select', 'function', 'modules/field/modules/options/options.module', 'options', '', '0'),
('theme_options_onoff', 'function', 'modules/field/modules/options/options.module', 'options', '', '0'),
('theme_options_buttons', 'function', 'modules/field/modules/options/options.module', 'options', '', '0'),
('number_theme', 'function', 'modules/field/modules/number/number.module', 'number', 'theme', '0'),
('number_field_info', 'function', 'modules/field/modules/number/number.module', 'number', 'field_info', '0'),
('number_field_schema', 'function', 'modules/field/modules/number/number.module', 'number', 'field_schema', '0'),
('number_field_validate', 'function', 'modules/field/modules/number/number.module', 'number', 'field_validate', '0'),
('number_field_is_empty', 'function', 'modules/field/modules/number/number.module', 'number', 'field_is_empty', '0'),
('number_field_formatter_info', 'function', 'modules/field/modules/number/number.module', 'number', 'field_formatter_info', '0'),
('theme_field_formatter_number_unformatted', 'function', 'modules/field/modules/number/number.module', 'number', '', '0'),
('theme_field_formatter_number', 'function', 'modules/field/modules/number/number.module', 'number', '', '0'),
('number_field_widget_info', 'function', 'modules/field/modules/number/number.module', 'number', 'field_widget_info', '0'),
('number_elements', 'function', 'modules/field/modules/number/number.module', 'number', 'elements', '0'),
('number_field_widget', 'function', 'modules/field/modules/number/number.module', 'number', 'field_widget', '0'),
('number_field_widget_error', 'function', 'modules/field/modules/number/number.module', 'number', 'field_widget_error', '0'),
('number_elements_process', 'function', 'modules/field/modules/number/number.module', 'number', 'elements_process', '0'),
('number_float_validate', 'function', 'modules/field/modules/number/number.module', 'number', 'float_validate', '0'),
('number_integer_validate', 'function', 'modules/field/modules/number/number.module', 'number', 'integer_validate', '0'),
('number_decimal_validate', 'function', 'modules/field/modules/number/number.module', 'number', 'decimal_validate', '0'),
('theme_number', 'function', 'modules/field/modules/number/number.module', 'number', '', '0'),
('list_theme', 'function', 'modules/field/modules/list/list.module', 'list', 'theme', '0'),
('list_field_info', 'function', 'modules/field/modules/list/list.module', 'list', 'field_info', '0'),
('list_field_schema', 'function', 'modules/field/modules/list/list.module', 'list', 'field_schema', '0'),
('list_field_validate', 'function', 'modules/field/modules/list/list.module', 'list', 'field_validate', '0'),
('list_field_is_empty', 'function', 'modules/field/modules/list/list.module', 'list', 'field_is_empty', '0'),
('list_field_formatter_info', 'function', 'modules/field/modules/list/list.module', 'list', 'field_formatter_info', '0'),
('theme_field_formatter_list_default', 'function', 'modules/field/modules/list/list.module', 'list', '', '0'),
('theme_field_formatter_list_key', 'function', 'modules/field/modules/list/list.module', 'list', '', '0'),
('list_allowed_values', 'function', 'modules/field/modules/list/list.module', 'list', 'allowed_values', '0'),
('field_sql_storage_help', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'help', '0'),
('_field_sql_storage_tablename', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('_field_sql_storage_revision_tablename', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('_field_sql_storage_columnname', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('_field_sql_storage_indexname', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('_field_sql_storage_etid', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('_field_sql_storage_schema', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', '', '0'),
('field_sql_storage_field_storage_create_field', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_create_field', '0'),
('field_sql_storage_field_storage_delete_field', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_delete_field', '0'),
('field_sql_storage_field_storage_load', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_load', '0'),
('field_sql_storage_field_storage_write', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_write', '0'),
('field_sql_storage_field_storage_delete', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_delete', '0'),
('field_sql_storage_field_storage_query', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_query', '0'),
('field_sql_storage_field_storage_delete_revision', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_delete_revision', '0'),
('field_sql_storage_field_storage_delete_instance', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_delete_instance', '0'),
('field_sql_storage_field_storage_rename_bundle', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'field_storage_rename_bundle', '0'),
('field_sql_storage_install', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.install', 'field_sql_storage', 'install', '0'),
('field_sql_storage_uninstall', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.install', 'field_sql_storage', 'uninstall', '0'),
('field_sql_storage_schema', 'function', 'modules/field/modules/field_sql_storage/field_sql_storage.install', 'field_sql_storage', 'schema', '0'),
('FieldSqlStorageTestCase', 'class', 'modules/field/modules/field_sql_storage/field_sql_storage.test', 'field_sql_storage', '', '0'),
('field_filter_xss', 'function', 'modules/field/field.module', 'field', 'filter_xss', '0'),
('field_cache_clear', 'function', 'modules/field/field.module', 'field', 'cache_clear', '0'),
('field_build_modes', 'function', 'modules/field/field.module', 'field', 'build_modes', '0'),
('_field_sort_items_value_helper', 'function', 'modules/field/field.module', 'field', '', '0'),
('_field_sort_items_helper', 'function', 'modules/field/field.module', 'field', '', '0'),
('_field_sort_items', 'function', 'modules/field/field.module', 'field', '', '0'),
('field_set_empty', 'function', 'modules/field/field.module', 'field', 'set_empty', '0'),
('field_associate_fields', 'function', 'modules/field/field.module', 'field', 'associate_fields', '0'),
('field_modules_disabled', 'function', 'modules/field/field.module', 'field', 'modules_disabled', '0'),
('field_modules_enabled', 'function', 'modules/field/field.module', 'field', 'modules_enabled', '0'),
('field_modules_uninstalled', 'function', 'modules/field/field.module', 'field', 'modules_uninstalled', '0'),
('field_modules_installed', 'function', 'modules/field/field.module', 'field', 'modules_installed', '0'),
('field_theme', 'function', 'modules/field/field.module', 'field', 'theme', '0'),
('field_menu', 'function', 'modules/field/field.module', 'field', 'menu', '0'),
('field_init', 'function', 'modules/field/field.module', 'field', 'init', '0'),
('field_help', 'function', 'modules/field/field.module', 'field', 'help', '0'),
('field_flush_caches', 'function', 'modules/field/field.module', 'field', 'flush_caches', '0'),
('FieldException', 'class', 'modules/field/field.module', 'field', '', '0'),
('field_install', 'function', 'modules/field/field.install', 'field', 'install', '0'),
('field_schema', 'function', 'modules/field/field.install', 'field', 'schema', '0'),
('field_read_instance', 'function', 'modules/field/field.crud.inc', 'field', 'read_instance', '0'),
('_field_write_instance', 'function', 'modules/field/field.crud.inc', 'field', '', '0'),
('field_update_instance', 'function', 'modules/field/field.crud.inc', 'field', 'update_instance', '0'),
('field_create_instance', 'function', 'modules/field/field.crud.inc', 'field', 'create_instance', '0'),
('field_delete_field', 'function', 'modules/field/field.crud.inc', 'field', 'delete_field', '0'),
('field_read_fields', 'function', 'modules/field/field.crud.inc', 'field', 'read_fields', '0'),
('field_read_field', 'function', 'modules/field/field.crud.inc', 'field', 'read_field', '0'),
('field_create_field', 'function', 'modules/field/field.crud.inc', 'field', 'create_field', '0'),
('_field_get_formatter', 'function', 'modules/field/field.info.inc', 'field', '', '0'),
('_field_info_collate_types', 'function', 'modules/field/field.info.inc', 'field', '', '0'),
('_field_info_collate_fields', 'function', 'modules/field/field.info.inc', 'field', '', '0'),
('field_behaviors_field', 'function', 'modules/field/field.info.inc', 'field', 'behaviors_field', '0'),
('field_behaviors_widget', 'function', 'modules/field/field.info.inc', 'field', 'behaviors_widget', '0'),
('field_behaviors_formatter', 'function', 'modules/field/field.info.inc', 'field', 'behaviors_formatter', '0'),
('field_info_field_types', 'function', 'modules/field/field.info.inc', 'field', 'info_field_types', '0'),
('field_info_widget_types', 'function', 'modules/field/field.info.inc', 'field', 'info_widget_types', '0'),
('field_info_formatter_types', 'function', 'modules/field/field.info.inc', 'field', 'info_formatter_types', '0'),
('field_info_fieldable_types', 'function', 'modules/field/field.info.inc', 'field', 'info_fieldable_types', '0'),
('field_info_bundles', 'function', 'modules/field/field.info.inc', 'field', 'info_bundles', '0'),
('field_info_bundle_entity', 'function', 'modules/field/field.info.inc', 'field', 'info_bundle_entity', '0'),
('field_info_fields', 'function', 'modules/field/field.info.inc', 'field', 'info_fields', '0'),
('field_info_field', 'function', 'modules/field/field.info.inc', 'field', 'info_field', '0'),
('field_info_instances', 'function', 'modules/field/field.info.inc', 'field', 'info_instances', '0'),
('field_info_instance', 'function', 'modules/field/field.info.inc', 'field', 'info_instance', '0'),
('field_info_field_settings', 'function', 'modules/field/field.info.inc', 'field', 'info_field_settings', '0'),
('field_info_instance_settings', 'function', 'modules/field/field.info.inc', 'field', 'info_instance_settings', '0'),
('field_info_widget_settings', 'function', 'modules/field/field.info.inc', 'field', 'info_widget_settings', '0'),
('field_info_formatter_settings', 'function', 'modules/field/field.info.inc', 'field', 'info_formatter_settings', '0'),
('field_attach_rename_bundle', 'function', 'modules/field/field.attach.inc', 'field', 'attach_rename_bundle', '0'),
('field_default_prepare_translation', 'function', 'modules/field/field.default.inc', 'field', 'default_prepare_translation', '0'),
('field_default_view', 'function', 'modules/field/field.default.inc', 'field', 'default_view', '0'),
('field_default_insert', 'function', 'modules/field/field.default.inc', 'field', 'default_insert', '0'),
('field_default_submit', 'function', 'modules/field/field.default.inc', 'field', 'default_submit', '0'),
('field_default_validate', 'function', 'modules/field/field.default.inc', 'field', 'default_validate', '0'),
('field_default_extract_form_values', 'function', 'modules/field/field.default.inc', 'field', 'default_extract_form_values', '0'),
('field_attach_create_bundle', 'function', 'modules/field/field.attach.inc', 'field', 'attach_create_bundle', '0'),
('field_attach_prepare_translation', 'function', 'modules/field/field.attach.inc', 'field', 'attach_prepare_translation', '0'),
('field_attach_view', 'function', 'modules/field/field.attach.inc', 'field', 'attach_view', '0'),
('field_attach_query_revisions', 'function', 'modules/field/field.attach.inc', 'field', 'attach_query_revisions', '0'),
('field_attach_query', 'function', 'modules/field/field.attach.inc', 'field', 'attach_query', '0'),
('field_attach_delete_revision', 'function', 'modules/field/field.attach.inc', 'field', 'attach_delete_revision', '0'),
('field_attach_delete', 'function', 'modules/field/field.attach.inc', 'field', 'attach_delete', '0'),
('field_attach_update', 'function', 'modules/field/field.attach.inc', 'field', 'attach_update', '0'),
('field_attach_insert', 'function', 'modules/field/field.attach.inc', 'field', 'attach_insert', '0'),
('field_attach_presave', 'function', 'modules/field/field.attach.inc', 'field', 'attach_presave', '0'),
('field_attach_submit', 'function', 'modules/field/field.attach.inc', 'field', 'attach_submit', '0'),
('field_attach_form_validate', 'function', 'modules/field/field.attach.inc', 'field', 'attach_form_validate', '0'),
('field_attach_validate', 'function', 'modules/field/field.attach.inc', 'field', 'attach_validate', '0'),
('field_attach_load_revision', 'function', 'modules/field/field.attach.inc', 'field', 'attach_load_revision', '0'),
('field_attach_load', 'function', 'modules/field/field.attach.inc', 'field', 'attach_load', '0'),
('field_attach_form', 'function', 'modules/field/field.attach.inc', 'field', 'attach_form', '0'),
('_field_invoke_multiple_default', 'function', 'modules/field/field.attach.inc', 'field', '', '0'),
('_field_invoke_default', 'function', 'modules/field/field.attach.inc', 'field', '', '0'),
('_field_invoke_multiple', 'function', 'modules/field/field.attach.inc', 'field', '', '0'),
('_field_invoke', 'function', 'modules/field/field.attach.inc', 'field', '', '0'),
('FieldQueryException', 'class', 'modules/field/field.attach.inc', 'field', '', '0'),
('FieldValidationException', 'class', 'modules/field/field.attach.inc', 'field', '', '0'),
('field_default_form', 'function', 'modules/field/field.form.inc', 'field', 'default_form', '0'),
('field_multiple_value_form', 'function', 'modules/field/field.form.inc', 'field', 'multiple_value_form', '0'),
('theme_field_multiple_value_form', 'function', 'modules/field/field.form.inc', 'field', '', '0'),
('field_default_form_errors', 'function', 'modules/field/field.form.inc', 'field', 'default_form_errors', '0'),
('field_add_more_submit', 'function', 'modules/field/field.form.inc', 'field', 'add_more_submit', '0'),
('field_add_more_js', 'function', 'modules/field/field.form.inc', 'field', 'add_more_js', '0'),
('FieldInstanceTestCase', 'class', 'modules/field/field.test', 'field', '', '0'),
('FieldCrudTestCase', 'class', 'modules/field/field.test', 'field', '', '0'),
('FieldFormTestCase', 'class', 'modules/field/field.test', 'field', '', '0'),
('FieldInfoTestCase', 'class', 'modules/field/field.test', 'field', '', '0'),
('FieldAttachTestCase', 'class', 'modules/field/field.test', 'field', '', '0'),
('block_list', 'function', 'modules/block/block.module', 'block', 'list', '-5'),
('block_initialize_theme_blocks', 'function', 'modules/block/block.module', 'block', 'initialize_theme_blocks', '-5'),
('block_system_themes_form_submit', 'function', 'modules/block/block.module', 'block', 'system_themes_form_submit', '-5'),
('block_form_system_themes_form_alter', 'function', 'modules/block/block.module', 'block', 'form_system_themes_form_alter', '-5'),
('block_form_system_performance_settings_alter', 'function', 'modules/block/block.module', 'block', 'form_system_performance_settings_alter', '-5'),
('block_user_validate', 'function', 'modules/block/block.module', 'block', 'user_validate', '-5'),
('block_user_form', 'function', 'modules/block/block.module', 'block', 'user_form', '-5'),
('block_box_save', 'function', 'modules/block/block.module', 'block', 'box_save', '-5'),
('block_box_form', 'function', 'modules/block/block.module', 'block', 'box_form', '-5'),
('block_box_get', 'function', 'modules/block/block.module', 'block', 'box_get', '-5'),
('_block_rehash', 'function', 'modules/block/block.module', 'block', '', '-5'),
('block_page_alter', 'function', 'modules/block/block.module', 'block', 'page_alter', '-5'),
('block_get_blocks_by_region', 'function', 'modules/block/block.module', 'block', 'get_blocks_by_region', '-5'),
('block_block_view', 'function', 'modules/block/block.module', 'block', 'block_view', '-5'),
('block_block_save', 'function', 'modules/block/block.module', 'block', 'block_save', '-5'),
('block_block_configure', 'function', 'modules/block/block.module', 'block', 'block_configure', '-5'),
('block_block_list', 'function', 'modules/block/block.module', 'block', 'block_list', '-5'),
('_block_themes_access', 'function', 'modules/block/block.module', 'block', '', '-5'),
('block_menu', 'function', 'modules/block/block.module', 'block', 'menu', '-5'),
('block_perm', 'function', 'modules/block/block.module', 'block', 'perm', '-5'),
('block_theme', 'function', 'modules/block/block.module', 'block', 'theme', '-5'),
('block_help', 'function', 'modules/block/block.module', 'block', 'help', '-5'),
('block_box_delete', 'function', 'modules/block/block.admin.inc', 'block', 'box_delete', '-5'),
('block_add_block_form_submit', 'function', 'modules/block/block.admin.inc', 'block', 'add_block_form_submit', '-5'),
('block_add_block_form_validate', 'function', 'modules/block/block.admin.inc', 'block', 'add_block_form_validate', '-5'),
('block_add_block_form', 'function', 'modules/block/block.admin.inc', 'block', 'add_block_form', '-5'),
('block_admin_configure_submit', 'function', 'modules/block/block.admin.inc', 'block', 'admin_configure_submit', '-5'),
('block_admin_configure_validate', 'function', 'modules/block/block.admin.inc', 'block', 'admin_configure_validate', '-5'),
('block_admin_configure', 'function', 'modules/block/block.admin.inc', 'block', 'admin_configure', '-5'),
('_block_compare', 'function', 'modules/block/block.admin.inc', 'block', '', '-5'),
('block_admin_display_form_submit', 'function', 'modules/block/block.admin.inc', 'block', 'admin_display_form_submit', '-5'),
('block_admin_display_form', 'function', 'modules/block/block.admin.inc', 'block', 'admin_display_form', '-5'),
('block_admin_display', 'function', 'modules/block/block.admin.inc', 'block', 'admin_display', '-5'),
('block_schema', 'function', 'modules/block/block.install', 'block', 'schema', '-5'),
('block_install', 'function', 'modules/block/block.install', 'block', 'install', '-5'),
('block_uninstall', 'function', 'modules/block/block.install', 'block', 'uninstall', '-5'),
('block_update_7000', 'function', 'modules/block/block.install', 'block', 'update_7000', '-5'),
('BlockTestCase', 'class', 'modules/block/block.test', 'block', '', '-5'),
('NonDefaultBlockAdmin', 'class', 'modules/block/block.test', 'block', '', '-5'),
('NewDefaultThemeBlocks', 'class', 'modules/block/block.test', 'block', '', '-5'),
('BlockAdminThemeTestCase', 'class', 'modules/block/block.test', 'block', '', '-5'),
('color_help', 'function', 'modules/color/color.module', 'color', 'help', '0'),
('color_theme', 'function', 'modules/color/color.module', 'color', 'theme', '0'),
('color_form_system_theme_settings_alter', 'function', 'modules/color/color.module', 'color', 'form_system_theme_settings_alter', '0'),
('color_form_system_themes_alter', 'function', 'modules/color/color.module', 'color', 'form_system_themes_alter', '0'),
('color_form_system_theme_select_form_alter', 'function', 'modules/color/color.module', 'color', 'form_system_theme_select_form_alter', '0'),
('_color_theme_select_form_alter', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_page_alter', 'function', 'modules/color/color.module', 'color', '', '0'),
('color_get_info', 'function', 'modules/color/color.module', 'color', 'get_info', '0'),
('color_get_palette', 'function', 'modules/color/color.module', 'color', 'get_palette', '0'),
('color_scheme_form', 'function', 'modules/color/color.module', 'color', 'scheme_form', '0'),
('theme_color_scheme_form', 'function', 'modules/color/color.module', 'color', '', '0'),
('color_scheme_form_submit', 'function', 'modules/color/color.module', 'color', 'scheme_form_submit', '0'),
('_color_rewrite_stylesheet', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_save_stylesheet', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_render_images', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_shift', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_gd', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_blend', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_unpack', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_pack', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_hsl2rgb', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_hue2rgb', 'function', 'modules/color/color.module', 'color', '', '0'),
('_color_rgb2hsl', 'function', 'modules/color/color.module', 'color', '', '0'),
('color_requirements', 'function', 'modules/color/color.install', 'color', 'requirements', '0'),
('_comment_per_page', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('_comment_get_modes', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_submitted', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('template_preprocess_comment_wrapper', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_post_forbidden', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_thread_expanded', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_thread_collapsed', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_flat_expanded', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_flat_collapsed', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('template_preprocess_comment_folded', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('template_preprocess_comment', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('theme_comment_view', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_form_submit', 'function', 'modules/comment/comment.module', 'comment', 'form_submit', '0'),
('_comment_form_submit', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_form_validate', 'function', 'modules/comment/comment.module', 'comment', 'form_validate', '0'),
('comment_form_add_preview', 'function', 'modules/comment/comment.module', 'comment', 'form_add_preview', '0'),
('theme_comment_form_box', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_form', 'function', 'modules/comment/comment.module', 'comment', 'form', '0'),
('comment_get_display_page', 'function', 'modules/comment/comment.module', 'comment', 'get_display_page', '0'),
('comment_get_display_ordinal', 'function', 'modules/comment/comment.module', 'comment', 'get_display_ordinal', '0'),
('comment_num_new', 'function', 'modules/comment/comment.module', 'comment', 'num_new', '0'),
('comment_num_replies', 'function', 'modules/comment/comment.module', 'comment', 'num_replies', '0'),
('comment_load', 'function', 'modules/comment/comment.module', 'comment', 'load', '0'),
('comment_operations', 'function', 'modules/comment/comment.module', 'comment', 'operations', '0'),
('comment_render', 'function', 'modules/comment/comment.module', 'comment', 'render', '0'),
('comment_links', 'function', 'modules/comment/comment.module', 'comment', 'links', '0'),
('comment_link', 'function', 'modules/comment/comment.module', 'comment', 'link', '0'),
('comment_save', 'function', 'modules/comment/comment.module', 'comment', 'save', '0'),
('comment_node_url', 'function', 'modules/comment/comment.module', 'comment', 'node_url', '0'),
('comment_access', 'function', 'modules/comment/comment.module', 'comment', 'access', '0'),
('comment_user_cancel', 'function', 'modules/comment/comment.module', 'comment', 'user_cancel', '0'),
('comment_node_search_result', 'function', 'modules/comment/comment.module', 'comment', 'node_search_result', '0'),
('comment_update_index', 'function', 'modules/comment/comment.module', 'comment', 'update_index', '0'),
('comment_node_update_index', 'function', 'modules/comment/comment.module', 'comment', 'node_update_index', '0'),
('comment_node_delete', 'function', 'modules/comment/comment.module', 'comment', 'node_delete', '0'),
('comment_node_insert', 'function', 'modules/comment/comment.module', 'comment', 'node_insert', '0'),
('comment_node_prepare', 'function', 'modules/comment/comment.module', 'comment', 'node_prepare', '0'),
('comment_node_load', 'function', 'modules/comment/comment.module', 'comment', 'node_load', '0'),
('comment_form_alter', 'function', 'modules/comment/comment.module', 'comment', 'form_alter', '0'),
('comment_form_node_type_form_alter', 'function', 'modules/comment/comment.module', 'comment', 'form_node_type_form_alter', '0'),
('comment_node_view', 'function', 'modules/comment/comment.module', 'comment', 'node_view', '0'),
('theme_comment_block', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_new_page_count', 'function', 'modules/comment/comment.module', 'comment', 'new_page_count', '0'),
('comment_get_recent', 'function', 'modules/comment/comment.module', 'comment', 'get_recent', '0'),
('comment_permalink', 'function', 'modules/comment/comment.module', 'comment', 'permalink', '0'),
('comment_block_view', 'function', 'modules/comment/comment.module', 'comment', 'block_view', '0'),
('comment_block_save', 'function', 'modules/comment/comment.module', 'comment', 'block_save', '0'),
('comment_block_configure', 'function', 'modules/comment/comment.module', 'comment', 'block_configure', '0'),
('comment_block_list', 'function', 'modules/comment/comment.module', 'comment', 'block_list', '0'),
('comment_perm', 'function', 'modules/comment/comment.module', 'comment', 'perm', '0'),
('comment_menu', 'function', 'modules/comment/comment.module', 'comment', 'menu', '0'),
('comment_node_type', 'function', 'modules/comment/comment.module', 'comment', 'node_type', '0'),
('comment_theme', 'function', 'modules/comment/comment.module', 'comment', 'theme', '0'),
('comment_help', 'function', 'modules/comment/comment.module', 'comment', 'help', '0'),
('comment_confirm_delete', 'function', 'modules/comment/comment.admin.inc', 'comment', 'confirm_delete', '0'),
('comment_delete', 'function', 'modules/comment/comment.admin.inc', 'comment', 'delete', '0'),
('comment_multiple_delete_confirm_submit', 'function', 'modules/comment/comment.admin.inc', 'comment', 'multiple_delete_confirm_submit', '0'),
('comment_multiple_delete_confirm', 'function', 'modules/comment/comment.admin.inc', 'comment', 'multiple_delete_confirm', '0'),
('comment_admin_overview_submit', 'function', 'modules/comment/comment.admin.inc', 'comment', 'admin_overview_submit', '0'),
('comment_admin_overview_validate', 'function', 'modules/comment/comment.admin.inc', 'comment', 'admin_overview_validate', '0'),
('comment_admin_overview', 'function', 'modules/comment/comment.admin.inc', 'comment', 'admin_overview', '0'),
('comment_admin', 'function', 'modules/comment/comment.admin.inc', 'comment', 'admin', '0'),
('comment_edit', 'function', 'modules/comment/comment.pages.inc', 'comment', 'edit', '0'),
('comment_reply', 'function', 'modules/comment/comment.pages.inc', 'comment', 'reply', '0'),
('comment_approve', 'function', 'modules/comment/comment.pages.inc', 'comment', 'approve', '0'),
('comment_schema', 'function', 'modules/comment/comment.install', 'comment', 'schema', '0'),
('comment_update_7003', 'function', 'modules/comment/comment.install', 'comment', 'update_7003', '0'),
('comment_update_7002', 'function', 'modules/comment/comment.install', 'comment', 'update_7002', '0'),
('comment_update_7001', 'function', 'modules/comment/comment.install', 'comment', 'update_7001', '0'),
('comment_update_7000', 'function', 'modules/comment/comment.install', 'comment', 'update_7000', '0'),
('comment_update_1', 'function', 'modules/comment/comment.install', 'comment', 'update_1', '0'),
('comment_enable', 'function', 'modules/comment/comment.install', 'comment', 'enable', '0'),
('comment_uninstall', 'function', 'modules/comment/comment.install', 'comment', 'uninstall', '0'),
('comment_install', 'function', 'modules/comment/comment.install', 'comment', 'install', '0'),
('CommentRSSUnitTest', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentBlockFunctionalTest', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentApprovalTest', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentPagerTest', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentAnonymous', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentInterfaceTest', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('CommentHelperCase', 'class', 'modules/comment/comment.test', 'comment', '', '0'),
('help_menu', 'function', 'modules/help/help.module', 'help', 'menu', '0'),
('help_help', 'function', 'modules/help/help.module', 'help', 'help', '0'),
('help_main', 'function', 'modules/help/help.admin.inc', 'help', 'main', '0'),
('help_page', 'function', 'modules/help/help.admin.inc', 'help', 'page', '0'),
('help_links_as_list', 'function', 'modules/help/help.admin.inc', 'help', 'links_as_list', '0'),
('HelpTestCase', 'class', 'modules/help/help.test', 'help', '', '0'),
('menu_help', 'function', 'modules/menu/menu.module', 'menu', 'help', '0'),
('menu_perm', 'function', 'modules/menu/menu.module', 'menu', 'perm', '0'),
('menu_menu', 'function', 'modules/menu/menu.module', 'menu', 'menu', '0'),
('menu_theme', 'function', 'modules/menu/menu.module', 'menu', 'theme', '0'),
('menu_enable', 'function', 'modules/menu/menu.module', 'menu', 'enable', '0'),
('menu_overview_title', 'function', 'modules/menu/menu.module', 'menu', 'overview_title', '0'),
('menu_load', 'function', 'modules/menu/menu.module', 'menu', 'load', '0'),
('menu_parent_options', 'function', 'modules/menu/menu.module', 'menu', 'parent_options', '0'),
('_menu_parents_recurse', 'function', 'modules/menu/menu.module', 'menu', '', '0'),
('menu_reset_item', 'function', 'modules/menu/menu.module', 'menu', 'reset_item', '0'),
('menu_block_list', 'function', 'modules/menu/menu.module', 'menu', 'block_list', '0'),
('menu_block_view', 'function', 'modules/menu/menu.module', 'menu', 'block_view', '0'),
('menu_node_insert', 'function', 'modules/menu/menu.module', 'menu', 'node_insert', '0'),
('menu_node_update', 'function', 'modules/menu/menu.module', 'menu', 'node_update', '0'),
('menu_node_delete', 'function', 'modules/menu/menu.module', 'menu', 'node_delete', '0'),
('menu_node_prepare', 'function', 'modules/menu/menu.module', 'menu', 'node_prepare', '0'),
('_menu_parent_depth_limit', 'function', 'modules/menu/menu.module', 'menu', '', '0'),
('menu_form_alter', 'function', 'modules/menu/menu.module', 'menu', 'form_alter', '0'),
('menu_node_form_submit', 'function', 'modules/menu/menu.module', 'menu', 'node_form_submit', '0'),
('menu_get_menus', 'function', 'modules/menu/menu.module', 'menu', 'get_menus', '0'),
('menu_item_delete_form', 'function', 'modules/menu/menu.admin.inc', 'menu', 'item_delete_form', '0'),
('menu_item_delete_page', 'function', 'modules/menu/menu.admin.inc', 'menu', 'item_delete_page', '0'),
('menu_edit_menu_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_menu_submit', '0'),
('menu_edit_menu_validate', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_menu_validate', '0'),
('menu_delete_menu_confirm_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'delete_menu_confirm_submit', '0'),
('menu_delete_menu_confirm', 'function', 'modules/menu/menu.admin.inc', 'menu', 'delete_menu_confirm', '0'),
('menu_delete_menu_page', 'function', 'modules/menu/menu.admin.inc', 'menu', 'delete_menu_page', '0'),
('menu_custom_delete_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'custom_delete_submit', '0'),
('menu_edit_menu', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_menu', '0'),
('menu_edit_item_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_item_submit', '0'),
('menu_item_delete_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'item_delete_submit', '0'),
('menu_edit_item_validate', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_item_validate', '0'),
('menu_edit_item', 'function', 'modules/menu/menu.admin.inc', 'menu', 'edit_item', '0'),
('theme_menu_overview_form', 'function', 'modules/menu/menu.admin.inc', 'menu', '', '0'),
('menu_overview_form_submit', 'function', 'modules/menu/menu.admin.inc', 'menu', 'overview_form_submit', '0'),
('_menu_overview_tree_form', 'function', 'modules/menu/menu.admin.inc', 'menu', '', '0'),
('menu_overview_form', 'function', 'modules/menu/menu.admin.inc', 'menu', 'overview_form', '0'),
('theme_menu_admin_overview', 'function', 'modules/menu/menu.admin.inc', 'menu', '', '0'),
('menu_overview_page', 'function', 'modules/menu/menu.admin.inc', 'menu', 'overview_page', '0'),
('menu_install', 'function', 'modules/menu/menu.install', 'menu', 'install', '0'),
('menu_uninstall', 'function', 'modules/menu/menu.install', 'menu', 'uninstall', '0'),
('menu_schema', 'function', 'modules/menu/menu.install', 'menu', 'schema', '0'),
('MenuTestCase', 'class', 'modules/menu/menu.test', 'menu', '', '0'),
('theme_taxonomy_term_select', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', '', '0'),
('_taxonomy_term_select', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', '', '0'),
('taxonomy_term_load', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_load', '0'),
('taxonomy_term_load_multiple', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_load_multiple', '0'),
('taxonomy_terms_load', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'terms_load', '0'),
('taxonomy_vocabulary_load', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'vocabulary_load', '0'),
('taxonomy_vocabulary_load_multiple', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'vocabulary_load_multiple', '0'),
('taxonomy_get_term_by_name', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_term_by_name', '0'),
('taxonomy_term_count_nodes', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_count_nodes', '0'),
('taxonomy_get_synonym_root', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_synonym_root', '0'),
('taxonomy_get_synonyms', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_synonyms', '0'),
('taxonomy_get_tree', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_tree', '0'),
('taxonomy_get_children', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_children', '0'),
('taxonomy_get_parents_all', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_parents_all', '0'),
('taxonomy_get_parents', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_parents', '0'),
('taxonomy_get_related', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_related', '0'),
('taxonomy_node_type', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_type', '0'),
('taxonomy_node_save', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_save', '0'),
('taxonomy_node_get_terms', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_get_terms', '0'),
('taxonomy_get_tids_from_nodes', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_tids_from_nodes', '0'),
('taxonomy_node_get_terms_by_vocabulary', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_get_terms_by_vocabulary', '0'),
('taxonomy_preview_terms', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'preview_terms', '0'),
('taxonomy_form_alter', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'form_alter', '0'),
('taxonomy_vocabulary_get_names', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'vocabulary_get_names', '0'),
('taxonomy_get_vocabularies', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'get_vocabularies', '0'),
('taxonomy_form_all', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'form_all', '0'),
('taxonomy_form', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'form', '0'),
('taxonomy_terms_static_reset', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'terms_static_reset', '0'),
('taxonomy_term_delete', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_delete', '0'),
('taxonomy_term_save', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_save', '0'),
('taxonomy_check_vocabulary_hierarchy', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'check_vocabulary_hierarchy', '0'),
('taxonomy_vocabulary_delete', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'vocabulary_delete', '0'),
('taxonomy_vocabulary_save', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'vocabulary_save', '0'),
('taxonomy_admin_vocabulary_title_callback', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'admin_vocabulary_title_callback', '0'),
('taxonomy_menu', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'menu', '0'),
('taxonomy_term_path', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'term_path', '0'),
('taxonomy_node_view', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_view', '0'),
('taxonomy_theme', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'theme', '0'),
('taxonomy_field_build_modes', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'field_build_modes', '0'),
('taxonomy_fieldable_info', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'fieldable_info', '0'),
('taxonomy_perm', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'perm', '0'),
('taxonomy_vocabulary_confirm_delete', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'vocabulary_confirm_delete', '0'),
('taxonomy_term_confirm_delete_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'term_confirm_delete_submit', '0'),
('taxonomy_term_confirm_delete', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'term_confirm_delete', '0'),
('taxonomy_term_confirm_parents', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'term_confirm_parents', '0'),
('taxonomy_form_term_submit_builder', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_term_submit_builder', '0'),
('taxonomy_form_term_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_term_submit', '0'),
('taxonomy_form_term_validate', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_term_validate', '0'),
('taxonomy_form_term', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_term', '0'),
('theme_taxonomy_overview_terms', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', '', '0'),
('taxonomy_overview_terms_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'overview_terms_submit', '0'),
('taxonomy_overview_terms', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'overview_terms', '0'),
('taxonomy_form_vocabulary_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_vocabulary_submit', '0'),
('taxonomy_form_vocabulary_validate', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_vocabulary_validate', '0'),
('taxonomy_form_vocabulary', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'form_vocabulary', '0'),
('theme_taxonomy_overview_vocabularies', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', '', '0'),
('taxonomy_overview_vocabularies', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'overview_vocabularies', '0'),
('taxonomy_overview_vocabularies_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'overview_vocabularies_submit', '0'),
('taxonomy_term_page', 'function', 'modules/taxonomy/taxonomy.pages.inc', 'taxonomy', 'term_page', '0'),
('taxonomy_term_edit', 'function', 'modules/taxonomy/taxonomy.pages.inc', 'taxonomy', 'term_edit', '0'),
('taxonomy_autocomplete', 'function', 'modules/taxonomy/taxonomy.pages.inc', 'taxonomy', 'autocomplete', '0'),
('taxonomy_install', 'function', 'modules/taxonomy/taxonomy.install', 'taxonomy', 'install', '0'),
('taxonomy_uninstall', 'function', 'modules/taxonomy/taxonomy.install', 'taxonomy', 'uninstall', '0'),
('taxonomy_schema', 'function', 'modules/taxonomy/taxonomy.install', 'taxonomy', 'schema', '0'),
('taxonomy_update_7002', 'function', 'modules/taxonomy/taxonomy.install', 'taxonomy', 'update_7002', '0'),
('TaxonomyLoadMultipleUnitTest', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('TaxonomyTermTestCase', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('TaxonomyTermUnitTest', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0');
INSERT INTO `registry` VALUES
('TaxonomyVocabularyUnitTest', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('TaxonomyVocabularyFunctionalTest', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('TaxonomyWebTestCase', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('dblog_clear_log_submit', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'clear_log_submit', '0'),
('dblog_clear_log_form', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'clear_log_form', '0'),
('dblog_filter_form_submit', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'filter_form_submit', '0'),
('dblog_filter_form_validate', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'filter_form_validate', '0'),
('dblog_filter_form', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'filter_form', '0'),
('dblog_filters', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'filters', '0'),
('_dblog_format_message', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', '', '0'),
('dblog_build_filter_query', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'build_filter_query', '0'),
('dblog_event', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'event', '0'),
('dblog_top', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'top', '0'),
('dblog_overview', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'overview', '0'),
('dblog_form_system_logging_settings_alter', 'function', 'modules/dblog/dblog.admin.inc', 'dblog', 'form_system_logging_settings_alter', '0'),
('theme_dblog_filters', 'function', 'modules/dblog/dblog.module', 'dblog', '', '0'),
('dblog_watchdog', 'function', 'modules/dblog/dblog.module', 'dblog', 'watchdog', '0'),
('_dblog_get_message_types', 'function', 'modules/dblog/dblog.module', 'dblog', '', '0'),
('dblog_user_cancel', 'function', 'modules/dblog/dblog.module', 'dblog', 'user_cancel', '0'),
('dblog_cron', 'function', 'modules/dblog/dblog.module', 'dblog', 'cron', '0'),
('dblog_init', 'function', 'modules/dblog/dblog.module', 'dblog', 'init', '0'),
('dblog_menu', 'function', 'modules/dblog/dblog.module', 'dblog', 'menu', '0'),
('dblog_theme', 'function', 'modules/dblog/dblog.module', 'dblog', 'theme', '0'),
('dblog_help', 'function', 'modules/dblog/dblog.module', 'dblog', 'help', '0'),
('admin_enable', 'function', 'modules/admin/admin.install', 'admin', 'enable', '0'),
('admin_install', 'function', 'modules/admin/admin.install', 'admin', 'install', '0'),
('admin_init', 'function', 'modules/admin/admin.module', 'admin', 'init', '0'),
('admin_perm', 'function', 'modules/admin/admin.module', 'admin', 'perm', '0'),
('admin_theme', 'function', 'modules/admin/admin.module', 'admin', 'theme', '0'),
('admin_is_enabled', 'function', 'modules/admin/admin.module', 'admin', 'is_enabled', '0'),
('admin_page_alter', 'function', 'modules/admin/admin.module', 'admin', 'page_alter', '0'),
('admin_preprocess_page', 'function', 'modules/admin/admin.module', 'admin', 'preprocess_page', '0'),
('admin_get_menu_tree', 'function', 'modules/admin/admin.module', 'admin', 'get_menu_tree', '0'),
('admin_toolbar', 'function', 'modules/admin/admin.module', 'admin', 'toolbar', '0'),
('admin_menu_navigation_links', 'function', 'modules/admin/admin.module', 'admin', 'menu_navigation_links', '0'),
('admin_in_active_trail', 'function', 'modules/admin/admin.module', 'admin', 'in_active_trail', '0'),
('update_help', 'function', 'modules/update/update.module', 'update', 'help', '0'),
('update_menu', 'function', 'modules/update/update.module', 'update', 'menu', '0'),
('update_theme', 'function', 'modules/update/update.module', 'update', 'theme', '0'),
('update_requirements', 'function', 'modules/update/update.module', 'update', 'requirements', '0'),
('_update_requirement_check', 'function', 'modules/update/update.module', 'update', '', '0'),
('update_cron', 'function', 'modules/update/update.module', 'update', 'cron', '0'),
('update_form_system_themes_form_alter', 'function', 'modules/update/update.module', 'update', 'form_system_themes_form_alter', '0'),
('update_form_system_modules_alter', 'function', 'modules/update/update.module', 'update', 'form_system_modules_alter', '0'),
('update_cache_clear_submit', 'function', 'modules/update/update.module', 'update', 'cache_clear_submit', '0'),
('_update_no_data', 'function', 'modules/update/update.module', 'update', '', '0'),
('update_get_available', 'function', 'modules/update/update.module', 'update', 'get_available', '0'),
('update_refresh', 'function', 'modules/update/update.module', 'update', 'refresh', '0'),
('update_mail', 'function', 'modules/update/update.module', 'update', 'mail', '0'),
('_update_message_text', 'function', 'modules/update/update.module', 'update', '', '0'),
('_update_project_status_sort', 'function', 'modules/update/update.module', 'update', '', '0'),
('_update_cache_set', 'function', 'modules/update/update.module', 'update', '', '0'),
('_update_cache_get', 'function', 'modules/update/update.module', 'update', '', '0'),
('_update_cache_clear', 'function', 'modules/update/update.module', 'update', '', '0'),
('update_flush_caches', 'function', 'modules/update/update.module', 'update', 'flush_caches', '0'),
('update_get_projects', 'function', 'modules/update/update.compare.inc', 'update', 'get_projects', '0'),
('_update_process_info_list', 'function', 'modules/update/update.compare.inc', 'update', '', '0'),
('update_get_project_name', 'function', 'modules/update/update.compare.inc', 'update', 'get_project_name', '0'),
('update_process_project_info', 'function', 'modules/update/update.compare.inc', 'update', 'process_project_info', '0'),
('update_calculate_project_data', 'function', 'modules/update/update.compare.inc', 'update', 'calculate_project_data', '0'),
('update_project_cache', 'function', 'modules/update/update.compare.inc', 'update', 'project_cache', '0'),
('update_manual_status', 'function', 'modules/update/update.fetch.inc', 'update', 'manual_status', '0'),
('_update_refresh', 'function', 'modules/update/update.fetch.inc', 'update', '', '0'),
('_update_build_fetch_url', 'function', 'modules/update/update.fetch.inc', 'update', '', '0'),
('_update_get_fetch_url_base', 'function', 'modules/update/update.fetch.inc', 'update', '', '0'),
('_update_cron_notify', 'function', 'modules/update/update.fetch.inc', 'update', '', '0'),
('update_parse_xml', 'function', 'modules/update/update.fetch.inc', 'update', 'parse_xml', '0'),
('update_status', 'function', 'modules/update/update.report.inc', 'update', 'status', '0'),
('theme_update_report', 'function', 'modules/update/update.report.inc', 'update', '', '0'),
('theme_update_version', 'function', 'modules/update/update.report.inc', 'update', '', '0'),
('update_settings', 'function', 'modules/update/update.settings.inc', 'update', 'settings', '0'),
('update_settings_validate', 'function', 'modules/update/update.settings.inc', 'update', 'settings_validate', '0'),
('update_settings_submit', 'function', 'modules/update/update.settings.inc', 'update', 'settings_submit', '0'),
('taxonomy_node_load', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_load', '0'),
('taxonomy_select_nodes', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'select_nodes', '0'),
('update_schema', 'function', 'modules/update/update.install', 'update', 'schema', '0'),
('update_uninstall', 'function', 'modules/update/update.install', 'update', 'uninstall', '0'),
('update_install', 'function', 'modules/update/update.install', 'update', 'install', '0'),
('modalframe_parent_js', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'parent_js', '0'),
('modalframe_form_submit', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'form_submit', '0'),
('modalframe_form_after_build_recursive', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'form_after_build_recursive', '0'),
('modalframe_form_after_build', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'form_after_build', '0'),
('modalframe_form_alter', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'form_alter', '0'),
('modalframe_preprocess_page', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'preprocess_page', '0'),
('modalframe_theme_registry_alter', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'theme_registry_alter', '0'),
('user_edit_validate', 'function', 'modules/user/user.pages.inc', 'user', 'edit_validate', '0'),
('user_cancel_methods', 'function', 'modules/user/user.pages.inc', 'user', 'cancel_methods', '0'),
('user_cancel_confirm', 'function', 'modules/user/user.pages.inc', 'user', 'cancel_confirm', '0'),
('d7uxoverlay_form_submit', 'function', 'sites/all/modules/d7uxoverlay/d7uxoverlay.module', 'd7uxoverlay', 'form_submit', '0'),
('d7uxoverlay_form_alter', 'function', 'sites/all/modules/d7uxoverlay/d7uxoverlay.module', 'd7uxoverlay', 'form_alter', '0'),
('d7uxoverlay_init', 'function', 'sites/all/modules/d7uxoverlay/d7uxoverlay.module', 'd7uxoverlay', 'init', '0'),
('popups_menu', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'menu', '9999'),
('popups_init', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'init', '9999'),
('popups_form_alter', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'form_alter', '9999'),
('popups_render_as_json', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'render_as_json', '9999'),
('popups_get_js', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'get_js', '9999'),
('popups_get_css', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'get_css', '9999'),
('popups_get_popups', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'get_popups', '9999'),
('popups_add_popups', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'add_popups', '9999'),
('popups_skins', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'skins', '9999'),
('popups_popups_skins', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'popups_skins', '9999'),
('_popups_default_content_selector', 'function', 'sites/all/modules/popups/popups.module', 'popups', '', '9999'),
('popups_admin_settings', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'admin_settings', '9999'),
('popups_theme_settings_form_submit', 'function', 'sites/all/modules/popups/popups.module', 'popups', 'theme_settings_form_submit', '9999'),
('taxonomy_node_delete', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_delete', '0'),
('taxonomy_node_update', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_update', '0'),
('taxonomy_node_insert', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_insert', '0'),
('user_page', 'function', 'modules/user/user.pages.inc', 'user', 'page', '0'),
('user_edit_submit', 'function', 'modules/user/user.pages.inc', 'user', 'edit_submit', '0'),
('taxonomy_node_delete_revision', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_delete_revision', '0'),
('taxonomy_node_validate', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_validate', '0'),
('taxonomy_node_update_index', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'node_update_index', '0'),
('taxonomy_terms_parse_string', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'terms_parse_string', '0'),
('taxonomy_help', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'help', '0'),
('_taxonomy_get_tid_from_term', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', '', '0'),
('taxonomy_implode_tags', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'implode_tags', '0'),
('taxonomy_hook_info', 'function', 'modules/taxonomy/taxonomy.module', 'taxonomy', 'hook_info', '0'),
('taxonomy_vocabulary_confirm_delete_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'vocabulary_confirm_delete_submit', '0'),
('taxonomy_vocabulary_confirm_reset_alphabetical', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'vocabulary_confirm_reset_alphabetical', '0'),
('taxonomy_vocabulary_confirm_reset_alphabetical_submit', 'function', 'modules/taxonomy/taxonomy.admin.inc', 'taxonomy', 'vocabulary_confirm_reset_alphabetical_submit', '0'),
('TaxonomyHooksTestCase', 'class', 'modules/taxonomy/taxonomy.test', 'taxonomy', '', '0'),
('system_send_email_action_submit', 'function', 'modules/system/system.module', 'system', 'send_email_action_submit', '0'),
('system_send_email_action', 'function', 'modules/system/system.module', 'system', 'send_email_action', '0'),
('system_mail', 'function', 'modules/system/system.module', 'system', 'mail', '0'),
('system_message_action_form', 'function', 'modules/system/system.module', 'system', 'message_action_form', '0'),
('system_message_action_submit', 'function', 'modules/system/system.module', 'system', 'message_action_submit', '0'),
('system_message_action', 'function', 'modules/system/system.module', 'system', 'message_action', '0'),
('system_goto_action_form', 'function', 'modules/system/system.module', 'system', 'goto_action_form', '0'),
('system_goto_action_submit', 'function', 'modules/system/system.module', 'system', 'goto_action_submit', '0'),
('system_goto_action', 'function', 'modules/system/system.module', 'system', 'goto_action', '0'),
('system_block_ip_action', 'function', 'modules/system/system.module', 'system', 'block_ip_action', '0'),
('system_time_zones', 'function', 'modules/system/system.module', 'system', 'time_zones', '0'),
('system_check_http_request', 'function', 'modules/system/system.module', 'system', 'check_http_request', '0'),
('system_timezone', 'function', 'modules/system/system.module', 'system', 'timezone', '0'),
('theme_system_powered_by', 'function', 'modules/system/system.module', 'system', '', '0'),
('theme_system_compact_link', 'function', 'modules/system/system.module', 'system', '', '0'),
('theme_meta_generator_html', 'function', 'modules/system/system.module', 'system', '', '0'),
('theme_meta_generator_header', 'function', 'modules/system/system.module', 'system', '', '0'),
('system_image_toolkits', 'function', 'modules/system/system.module', 'system', 'image_toolkits', '0'),
('system_retrieve_file', 'function', 'modules/system/system.module', 'system', 'retrieve_file', '0'),
('field_view_field', 'function', 'modules/field/field.module', 'field', 'view_field', '0'),
('field_access', 'function', 'modules/field/field.module', 'field', 'access', '0'),
('template_preprocess_field', 'function', 'modules/field/field.module', 'field', '', '0'),
('field_read_instances', 'function', 'modules/field/field.crud.inc', 'field', 'read_instances', '0'),
('field_delete_instance', 'function', 'modules/field/field.crud.inc', 'field', 'delete_instance', '0'),
('field_attach_delete_bundle', 'function', 'modules/field/field.attach.inc', 'field', 'attach_delete_bundle', '0'),
('field_attach_extract_ids', 'function', 'modules/field/field.attach.inc', 'field', 'attach_extract_ids', '0'),
('field_attach_create_stub_object', 'function', 'modules/field/field.attach.inc', 'field', 'attach_create_stub_object', '0'),
('_comment_get_display_setting', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('_comment_update_node_statistics', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_invoke_comment', 'function', 'modules/comment/comment.module', 'comment', 'invoke_comment', '0'),
('int2vancode', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('vancode2int', 'function', 'modules/comment/comment.module', 'comment', '', '0'),
('comment_hook_info', 'function', 'modules/comment/comment.module', 'comment', 'hook_info', '0'),
('comment_action_info', 'function', 'modules/comment/comment.module', 'comment', 'action_info', '0'),
('comment_unpublish_action', 'function', 'modules/comment/comment.module', 'comment', 'unpublish_action', '0'),
('comment_unpublish_by_keyword_action_form', 'function', 'modules/comment/comment.module', 'comment', 'unpublish_by_keyword_action_form', '0'),
('comment_unpublish_by_keyword_action_submit', 'function', 'modules/comment/comment.module', 'comment', 'unpublish_by_keyword_action_submit', '0'),
('comment_unpublish_by_keyword_action', 'function', 'modules/comment/comment.module', 'comment', 'unpublish_by_keyword_action', '0'),
('comment_ranking', 'function', 'modules/comment/comment.module', 'comment', 'ranking', '0'),
('comment_menu_alter', 'function', 'modules/comment/comment.module', 'comment', 'menu_alter', '0'),
('comment_confirm_delete_submit', 'function', 'modules/comment/comment.admin.inc', 'comment', 'confirm_delete_submit', '0'),
('_comment_delete_thread', 'function', 'modules/comment/comment.admin.inc', 'comment', '', '0'),
('_block_load_blocks', 'function', 'modules/block/block.module', 'block', '', '-5'),
('block_block_list_alter', 'function', 'modules/block/block.module', 'block', 'block_list_alter', '-5'),
('_block_render_blocks', 'function', 'modules/block/block.module', 'block', '', '-5'),
('_block_get_cache_id', 'function', 'modules/block/block.module', 'block', '', '-5'),
('block_flush_caches', 'function', 'modules/block/block.module', 'block', 'flush_caches', '-5'),
('template_preprocess_block', 'function', 'modules/block/block.module', 'block', '', '-5'),
('block_box_delete_submit', 'function', 'modules/block/block.admin.inc', 'block', 'box_delete_submit', '-5'),
('template_preprocess_block_admin_display_form', 'function', 'modules/block/block.admin.inc', 'block', '', '-5'),
('modalframe_child_js', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'child_js', '0'),
('modalframe_close_dialog', 'function', 'sites/all/modules/modalframe/modalframe.module', 'modalframe', 'close_dialog', '0'),
('FileTransfer', 'class', 'includes/filetransfer/filetransfer.inc', '', '', '0'),
('FileTransferException', 'class', 'includes/filetransfer/filetransfer.inc', '', '', '0'),
('FileTransferFTP', 'class', 'includes/filetransfer/ftp.inc', '', '', '0'),
('FileTransferFTPWrapper', 'class', 'includes/filetransfer/ftp.inc', '', '', '0'),
('FileTransferFTPExtension', 'class', 'includes/filetransfer/ftp.inc', '', '', '0'),
('FileTransferSSH', 'class', 'includes/filetransfer/ssh.inc', '', '', '0'),
('db_drop_unique_key', 'function', 'includes/database/database.inc', '', '', '0'),
('db_add_index', 'function', 'includes/database/database.inc', '', '', '0'),
('db_drop_index', 'function', 'includes/database/database.inc', '', '', '0'),
('db_change_field', 'function', 'includes/database/database.inc', '', '', '0'),
('_db_error_page', 'function', 'includes/database/database.inc', '', '', '0'),
('db_fetch_object', 'function', 'includes/database/database.inc', '', '', '0'),
('db_fetch_array', 'function', 'includes/database/database.inc', '', '', '0'),
('db_result', 'function', 'includes/database/database.inc', '', '', '0'),
('_db_check_install_needed', 'function', 'includes/database/database.inc', '', '', '0'),
('_db_query_process_args', 'function', 'includes/database/database.inc', '', '', '0'),
('db_last_insert_id', 'function', 'includes/database/database.inc', '', '', '0'),
('db_affected_rows', 'function', 'includes/database/database.inc', '', '', '0'),
('_db_rewrite_sql', 'function', 'includes/database/database.inc', '', '', '0'),
('db_rewrite_sql', 'function', 'includes/database/database.inc', '', '', '0'),
('db_or', 'function', 'includes/database/query.inc', '', '', '0'),
('db_and', 'function', 'includes/database/query.inc', '', '', '0'),
('db_xor', 'function', 'includes/database/query.inc', '', '', '0'),
('db_condition', 'function', 'includes/database/query.inc', '', '', '0'),
('DrupalDatabaseCache', 'class', 'includes/cache.inc', '', '', '0'),
('drupal_install_mkdir', 'function', 'includes/install.inc', '', '', '0'),
('drupal_install_fix_file', 'function', 'includes/install.inc', '', '', '0'),
('install_goto', 'function', 'includes/install.inc', '', '', '0'),
('st', 'function', 'includes/install.inc', '', '', '0'),
('drupal_check_profile', 'function', 'includes/install.inc', '', '', '0'),
('drupal_requirements_severity', 'function', 'includes/install.inc', '', '', '0'),
('drupal_check_module', 'function', 'includes/install.inc', '', '', '0'),
('_module_implements_maintenance', 'function', 'includes/module.inc', '', '', '0'),
('module_invoke', 'function', 'includes/module.inc', '', '', '0'),
('module_invoke_all', 'function', 'includes/module.inc', '', '', '0'),
('drupal_required_modules', 'function', 'includes/module.inc', '', '', '0'),
('demo_perm', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'perm', '0'),
('demo_menu', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'menu', '0'),
('demo_block', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'block', '0'),
('demo_reset_now', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'reset_now', '0'),
('demo_reset_now_submit', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'reset_now_submit', '0'),
('demo_cron', 'function', 'sites/all/modules/demo/demo.module', 'demo', 'cron', '0'),
('demo_admin_settings', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'admin_settings', '0'),
('demo_admin_settings_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'admin_settings_submit', '0'),
('demo_manage', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'manage', '0'),
('demo_manage_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'manage_submit', '0'),
('demo_manage_delete_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'manage_delete_submit', '0'),
('demo_delete_confirm', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'delete_confirm', '0'),
('demo_delete_confirm_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'delete_confirm_submit', '0'),
('demo_dump', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'dump', '0'),
('demo_dump_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'dump_submit', '0'),
('demo_reset_confirm', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'reset_confirm', '0'),
('demo_reset_confirm_submit', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'reset_confirm_submit', '0'),
('demo_reset', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'reset', '0'),
('demo_get_fileconfig', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'get_fileconfig', '0'),
('demo_get_dumps', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'get_dumps', '0'),
('demo_get_info', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'get_info', '0'),
('demo_set_info', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'set_info', '0'),
('demo_enum_tables', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'enum_tables', '0'),
('demo_autocomplete', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'autocomplete', '0'),
('demo_set_default', 'function', 'sites/all/modules/demo/demo.admin.inc', 'demo', 'set_default', '0'),
('demo_dump_db', 'function', 'sites/all/modules/demo/database_mysql_dump.inc', 'demo', 'dump_db', '0'),
('_demo_get_database', 'function', 'sites/all/modules/demo/database_mysql_dump.inc', 'demo', '', '0'),
('_demo_dump_table_structure', 'function', 'sites/all/modules/demo/database_mysql_dump.inc', 'demo', '', '0'),
('_demo_dump_table_data', 'function', 'sites/all/modules/demo/database_mysql_dump.inc', 'demo', '', '0'),
('_demo_get_fields', 'function', 'sites/all/modules/demo/database_mysql_dump.inc', 'demo', '', '0'),
('dblog_install', 'function', 'modules/dblog/dblog.install', 'dblog', 'install', '0'),
('dblog_uninstall', 'function', 'modules/dblog/dblog.install', 'dblog', 'uninstall', '0'),
('dblog_schema', 'function', 'modules/dblog/dblog.install', 'dblog', 'schema', '0'),
('dblog_update_7001', 'function', 'modules/dblog/dblog.install', 'dblog', 'update_7001', '0'),
('dblog_update_7002', 'function', 'modules/dblog/dblog.install', 'dblog', 'update_7002', '0'),
('dblog_update_7003', 'function', 'modules/dblog/dblog.install', 'dblog', 'update_7003', '0'),
('DBLogTestCase', 'class', 'modules/dblog/dblog.test', 'dblog', '', '0');
/*!40000 ALTER TABLE registry ENABLE KEYS */;

--
-- Table structure for table 'registry_file'
--

CREATE TABLE IF NOT EXISTS `registry_file` (
  `filename` varchar(255) NOT NULL COMMENT 'Path to the file.',
  `md5` varchar(32) NOT NULL COMMENT 'Md5 hash of the file’s contents when last parsed.',
  PRIMARY KEY  (`filename`)
);

--
-- Dumping data for table 'registry_file'
--

/*!40000 ALTER TABLE registry_file DISABLE KEYS */;
INSERT INTO `registry_file` VALUES
('modules/user/user.module', '82e14329214334e86868381c646d384e'),
('modules/user/user.admin.inc', 'c158a0d2a7bc391993165c0d84f9836e'),
('modules/user/user.pages.inc', '691482f26135c3f3889fa9f2b43bcc3f'),
('modules/user/user.install', '4bf9a28da6aa67d377e4cf92edcabc5c'),
('modules/user/user.test', '48c80b59919979e4e2140c168eb1fcf8'),
('modules/system/system.module', 'e054c512241ea974bcd7bb5ea0208825'),
('modules/system/system.admin.inc', 'c2db5f1f4ea154978a8d3288cb5473fc'),
('modules/system/system.queue.inc', '993a1ccba22f60b541556cf07d848823'),
('modules/system/image.gd.inc', '167e2321f000a95b0a22387ce19f1d04'),
('modules/system/system.install', 'e4deac6848abfdff215dbd784da36eae'),
('modules/system/system.test', '928153cbcb09feb2829c36ab2b72a09b'),
('modules/system/system.tar.inc', 'f0201c33ca9f4a74f52c475b9301548a'),
('includes/database/sqlite/database.inc', 'f2a114f0f309b2bd6609d96495e59922'),
('includes/database/sqlite/install.inc', '2809e1e449af96a12b7d93aa2bfc6f68'),
('includes/database/sqlite/query.inc', 'f2359ec7104c02b467e3f6624403ca5e'),
('includes/database/sqlite/schema.inc', 'a5f902f992a16c01cdd844f74d80df0c'),
('includes/database/pgsql/database.inc', '0e1c5e6ff40f7895b4b09304e4bcb173'),
('includes/database/pgsql/install.inc', '9f318a1c0cab4ddd92b3ffd06b3f696d'),
('includes/database/pgsql/query.inc', '0ed3e882bcec0d8112c9d0d865d55fe5'),
('includes/database/pgsql/schema.inc', '10a7afd6ef549c3f503375104c025888'),
('includes/database/mysql/database.inc', '8c07072d85caef79daf4db94ee66cf15'),
('includes/database/mysql/install.inc', 'a1309d14e3d94bd296d164c395de3da3'),
('includes/database/mysql/query.inc', 'f65e39ae84a6df01bf089c136af1234f'),
('includes/database/mysql/schema.inc', 'f8558ce84e2ba86e4c921099062c9a2b'),
('includes/database/database.inc', 'f0923d8d03bbf5bdc923354b872e2255'),
('includes/database/log.inc', '641fa919728cf4dfd39d8d0769afe903'),
('includes/database/prefetch.inc', 'b200119a39b89a9c6fce692116a3c554'),
('includes/database/query.inc', '57089d675f529114a0a2d25339b53bd6'),
('includes/database/schema.inc', 'de1c7ff60eb20c84e02afa16f8996017'),
('includes/database/select.inc', '2664ab492d4e0ba50f06238b659066bf'),
('includes/actions.inc', '789f9fb93b618832c50bef1aa8b3b905'),
('includes/batch.inc', '28345830b76a33cc79eb3e265e3399f9'),
('includes/bootstrap.inc', '72822934311e6000940c5b5a18c3b5c2'),
('includes/cache-install.inc', 'cd3c6af1d5b2f8fa9e517a81dbffdec9'),
('includes/cache.inc', '4b8c473c54c7793adad6f34d9cb2346e'),
('includes/common.inc', '4c640ec899d201062345e284dd3cac31'),
('includes/file.inc', 'cc8697f1fb625808c3086022232d4680'),
('includes/file.mimetypes.inc', 'e2cbea6dfe9ab01c23b7b9be838b3096'),
('includes/form.inc', '4b996527ad7deccadb3840a574c20a29'),
('includes/graph.inc', 'bea089408475fb6a1e02e986d4da93db'),
('includes/image.inc', '7fbba4c63c099455ff2b640e2b275856'),
('includes/install.inc', 'fd43f82a373ac1bb414d327ab4b45e88'),
('includes/iso.inc', 'add125c048a4a49cb49abd1a11d614e0'),
('includes/language.inc', '6ad76ebebf77574018e2f07a7cc11373'),
('includes/locale.inc', 'eb8cbbab6dd47a71d8bc682b96de59a3'),
('includes/mail.inc', 'eda79709f6de2f09c56dc5bdad3ba706'),
('includes/menu.inc', '61e5c0276e59f18e43b6f4d2cbb4ddd5'),
('includes/module.inc', '6feb5b3584147ed3eef0063591efe5bc'),
('includes/pager.inc', 'ed9f185929a8a9a8925ddc9fe59a5ee6'),
('includes/password.inc', '38d451c34693b822bfc988e9545f9fec'),
('includes/path.inc', '181224641a0a59c998ad6b742504ae8a'),
('includes/registry.inc', 'da46df7e142ec82b037506fdd569d851'),
('includes/session.inc', 'bbee16ce0c81e58d6f3ceac9e98f33f2'),
('includes/tablesort.inc', 'a7e5001517547a4ff73c866ce229c856'),
('includes/theme.inc', '91cde9ee6613fec92535c6ca893140aa'),
('includes/theme.maintenance.inc', '1ab894de958a655c29edefc88acbbe2f'),
('includes/unicode.entities.inc', 'a6fbe1c21364c4e09e335bbac58e5fbb'),
('includes/unicode.inc', '808b00d4d688e7966273bfd9cad73d7c'),
('includes/xmlrpc.inc', '3667cfa50c665308bf71aa175a9a890e'),
('includes/xmlrpcs.inc', '5165a4e5859ef29afc793e4c5ecd20db'),
('modules/node/node.module', '8be742fafa0911b07ad3e07505f53356'),
('modules/node/content_types.inc', 'b8b79b7431338406f656e0189cd23e8c'),
('modules/node/node.admin.inc', '61f98b234a96ece33f6e1fac2b39eb0a'),
('modules/node/node.pages.inc', '19b5620f73a4811a7f6c2b88542ee4ca'),
('modules/node/node.install', 'f6d5226a575b6ac62c33936eef3720e0'),
('modules/node/node.test', '0ae1eb5627072159fab5966731472c11'),
('modules/filter/filter.module', '891e7970cbca8b8fcc1a085e0dda2f17'),
('modules/filter/filter.admin.inc', 'b4d9b8d255fd9d14fe270f00db0d1888'),
('modules/filter/filter.pages.inc', 'e2ba6710197336788ff35aff71a5d055'),
('modules/filter/filter.install', 'b8bd84e373698616791053a57475d02e'),
('modules/filter/filter.test', '3c56935ed3601476d10580afee34f768'),
('modules/field/modules/text/text.module', '03530265afd37eae430228980ea4c67e'),
('modules/field/modules/text/text.test', '2fadc2e800cbd3f59a695f58febfd0eb'),
('modules/field/modules/options/options.module', 'bbb8d00b91da51016c840489fb5822d3'),
('modules/field/modules/number/number.module', 'bbbe581f76c6e6781d824603c8a2ea7d'),
('modules/field/modules/list/list.module', 'dad4c5fb88bd83022308e2cd635a8518'),
('modules/field/modules/field_sql_storage/field_sql_storage.module', '42ed62488e464f52e00e133cc8013a24'),
('modules/field/modules/field_sql_storage/field_sql_storage.install', '41b8d1fc706e4aaeef344a10e0ff6c65'),
('modules/field/modules/field_sql_storage/field_sql_storage.test', '5934ea7c1d609172c20b27a9634d53dd'),
('modules/field/field.module', 'ec80f1161277c75d5697b3b43c5600c9'),
('modules/field/field.install', '42e915b71d12b19f8fd71e8e021f789b'),
('modules/field/field.crud.inc', 'a3e8c050bac2dc6a044440951cca90ec'),
('modules/field/field.info.inc', 'cf3b77cea8901f952e409c8869ca83a2'),
('modules/field/field.default.inc', '62898925471410d62c12cd3818427338'),
('modules/field/field.attach.inc', '31402f14f6a81a5936762e46aaeb9fd0'),
('modules/field/field.form.inc', '3f4aa76b24839639e07365ee7d40785a'),
('modules/field/field.test', 'ae67d0c0c84a51f6d882c9d377f6b880'),
('modules/block/block.module', '82e995806d26160d4b0654ce118ef2f7'),
('modules/block/block.admin.inc', 'be1404f56b801d674df8e7f50c6048bb'),
('modules/block/block.install', '0bad6913c810c4d416054ca019a3dec3'),
('modules/block/block.test', '615bd2538206ec6bb1342d69ff6b4c54'),
('modules/color/color.module', '50427014d599d1b237f545bcad87240b'),
('modules/color/color.install', '0357f89bbe508ed6f38ef3f52f9359c4'),
('modules/comment/comment.module', '8f5adbfcdd607569482d8917808c8fea'),
('modules/comment/comment.admin.inc', '9619a15e9d2454046919feb0548f2829'),
('modules/comment/comment.pages.inc', 'c724c64e2ae72e2c535c1c6416cfc61f'),
('modules/comment/comment.install', '18e46fbd6bc9b254247e3e21b304c8f0'),
('modules/comment/comment.test', '399d228f3afa05d2cb1c337ad423e202'),
('modules/help/help.module', 'bcf3eb566db2657b2d81825b0da5b704'),
('modules/help/help.admin.inc', '1c061ecbcd73d9b9ef0fe1dcc4ece4d6'),
('modules/help/help.test', '89ecce70b86b2ad7024fc7a8ca37f2d3'),
('modules/menu/menu.module', '332ea105091a744dd9e78725544bbae2'),
('modules/menu/menu.admin.inc', 'b9ee0c4d19b73cad987967ef989debe1'),
('modules/menu/menu.install', 'e8b2d77a542d9ef7747de34cde87eea6'),
('modules/menu/menu.test', 'f736fb8ce6e0e14be72c7ca4726562e0'),
('modules/taxonomy/taxonomy.module', '17999a970f3e247b2ab80afa2f4f7d0c'),
('modules/taxonomy/taxonomy.admin.inc', 'c3009c28f37386c9027856258d1e3c47'),
('modules/taxonomy/taxonomy.pages.inc', 'ee4469b29fa8bcc8d2cfc979885a3579'),
('modules/taxonomy/taxonomy.install', '3ec3c5a07598a7b1f7e894852a09e258'),
('modules/taxonomy/taxonomy.test', '1321bc714d99a47dc5f4d566fdf909e0'),
('modules/dblog/dblog.install', '837754d442436632d820b7af02bd51bb'),
('modules/dblog/dblog.admin.inc', '8c647c7ef7a577ca82f04d4d83069e43'),
('modules/dblog/dblog.module', '0d9fcfdc818936f7e776567da17251a6'),
('modules/admin/admin.install', '024266fe439f40726a05e5521160dc57'),
('modules/admin/admin.module', '1f690ccf160b2b96e8bbc66e715cf458'),
('modules/update/update.module', '1ca22f9567848719a3eeb793aeab4481'),
('modules/update/update.compare.inc', '12597ddc98c2ffa6cfb4d2fe74dbd550'),
('modules/update/update.fetch.inc', '4d8baf344039dcca69ba790cfdafc744'),
('modules/update/update.report.inc', 'c080f813a249bedd7946237655c4ac44'),
('modules/update/update.settings.inc', '584f86283fe2be462a6ef244a128881a'),
('modules/update/update.install', '1a4c9f2f7b90370cf9aa1f81b137d13e'),
('sites/all/modules/modalframe/modalframe.module', '9c85a8cafeac15dfd524e0ed7e3d9e00'),
('includes/filetransfer/ftp.inc', '368086fae3424129a8943f18405cb36f'),
('includes/filetransfer/filetransfer.inc', '36335dbc67cd6e552911f75e340afd2e'),
('sites/all/modules/d7uxoverlay/d7uxoverlay.module', '854a416fe2110e786c4e68c4bff325a1'),
('sites/all/modules/popups/popups.module', '75274f13d38101d45480c54b999bd39c'),
('sites/all/modules/demo/demo.module', '83ad3a19dee0ff081d161cbe798358c7'),
('includes/filetransfer/ssh.inc', 'aeb264763cf25f9f16295d5552030a28'),
('sites/all/modules/demo/demo.admin.inc', 'f544162425f07a1fc69336a8370fd155'),
('sites/all/modules/demo/database_mysql_dump.inc', '4c6d6ab5f8aba9213504e73cc503459e'),
('modules/dblog/dblog.test', 'b5b7a162d663dfd2d84a46be3e08562f');
/*!40000 ALTER TABLE registry_file ENABLE KEYS */;

--
-- Table structure for table 'role'
--

CREATE TABLE IF NOT EXISTS `role` (
  `rid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique role ID.',
  `name` varchar(64) NOT NULL default '' COMMENT 'Unique role name.',
  PRIMARY KEY  (`rid`),
  UNIQUE KEY `name` (`name`)
);

--
-- Dumping data for table 'role'
--

/*!40000 ALTER TABLE role DISABLE KEYS */;
INSERT INTO `role` VALUES
('1', 'anonymous user'),
('2', 'authenticated user');
/*!40000 ALTER TABLE role ENABLE KEYS */;

--
-- Table structure for table 'role_permission'
--

CREATE TABLE IF NOT EXISTS `role_permission` (
  `rid` int(10) unsigned NOT NULL COMMENT 'Foreign Key: role.rid.',
  `permission` varchar(64) NOT NULL default '' COMMENT 'A single permission granted to the role identified by rid.',
  PRIMARY KEY  (`rid`,`permission`),
  KEY `permission` (`permission`)
);

--
-- Dumping data for table 'role_permission'
--

/*!40000 ALTER TABLE role_permission DISABLE KEYS */;
INSERT INTO `role_permission` VALUES
('1', 'access administration pages'),
('1', 'access comments'),
('1', 'access content'),
('1', 'access site reports'),
('1', 'access user profiles'),
('1', 'admin toolbar'),
('1', 'administer actions'),
('1', 'administer blocks'),
('1', 'administer comments'),
('1', 'administer content types'),
('1', 'administer files'),
('1', 'administer menu'),
('1', 'administer nodes'),
('1', 'administer site configuration'),
('1', 'administer taxonomy'),
('1', 'bypass node access'),
('1', 'create article content'),
('1', 'create page content'),
('1', 'delete any article content'),
('1', 'delete any page content'),
('1', 'delete own article content'),
('1', 'delete own page content'),
('1', 'delete revisions'),
('1', 'edit any article content'),
('1', 'edit any page content'),
('1', 'edit own article content'),
('1', 'edit own page content'),
('1', 'post comments'),
('1', 'post comments without approval'),
('1', 'revert revisions'),
('1', 'select different theme'),
('1', 'view revisions'),
('2', 'access comments'),
('2', 'access content'),
('2', 'post comments'),
('2', 'post comments without approval');
/*!40000 ALTER TABLE role_permission ENABLE KEYS */;

--
-- Table structure for table 'sessions'
--

CREATE TABLE IF NOT EXISTS `sessions` (
  `uid` int(10) unsigned NOT NULL COMMENT 'The users.uid corresponding to a session, or 0 for anonymous user.',
  `sid` varchar(64) NOT NULL default '' COMMENT 'Primary key: A session ID. The value is generated by PHP’s Session API.',
  `hostname` varchar(128) NOT NULL default '' COMMENT 'The IP address that last used this session ID (sid).',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'The Unix timestamp when this session last requested a page. Old records are purged by PHP automatically.',
  `cache` int(11) NOT NULL default '0' COMMENT 'The time of this user’s last post. This is used when the site has specified a minimum_cache_lifetime. See cache_get().',
  `session` longtext COMMENT 'The serialized contents of $_SESSION, an array of name/value pairs that persists across page requests by this session ID. Drupal loads $_SESSION from here at the start of each request and saves it at the end.',
  PRIMARY KEY  (`sid`),
  KEY `timestamp` (`timestamp`),
  KEY `uid` (`uid`)
);

--
-- Dumping data for table 'sessions'
--

/*!40000 ALTER TABLE sessions DISABLE KEYS */;
INSERT INTO `sessions` VALUES
('1', 'gra12uquiom0aijfmdr7j884l0', '127.0.0.1', '1246392248', '0', '');
/*!40000 ALTER TABLE sessions ENABLE KEYS */;

--
-- Table structure for table 'system'
--

CREATE TABLE IF NOT EXISTS `system` (
  `filename` varchar(255) NOT NULL default '' COMMENT 'The path of the primary file for this item, relative to the Drupal root; e.g. modules/node/node.module.',
  `name` varchar(255) NOT NULL default '' COMMENT 'The name of the item; e.g. node.',
  `type` varchar(12) NOT NULL default '' COMMENT 'The type of the item, either module, theme, or theme_engine.',
  `owner` varchar(255) NOT NULL default '' COMMENT 'A theme’s ’parent’ . Can be either a theme or an engine.',
  `status` int(11) NOT NULL default '0' COMMENT 'Boolean indicating whether or not this item is enabled.',
  `schema_version` smallint(6) NOT NULL default '-1' COMMENT 'The module’s database schema version number. -1 if the module is not installed (its tables do not exist); 0 or the largest N of the module’s hook_update_N() function that has either been run or existed when the module was first installed.',
  `weight` int(11) NOT NULL default '0' COMMENT 'The order in which this module’s hooks should be invoked relative to other modules. Equal-weighted modules are ordered by name.',
  `info` text COMMENT 'A serialized array containing information from the module’s .info file; keys can include name, description, package, version, core, dependencies, dependents, and php.',
  PRIMARY KEY  (`filename`),
  KEY `modules` (`type`,`status`,`weight`,`filename`),
  KEY `type_name` (`type`,`name`)
);

--
-- Dumping data for table 'system'
--

/*!40000 ALTER TABLE system DISABLE KEYS */;
INSERT INTO `system` VALUES
('themes/garland/garland.info', 'garland', 'theme', 'themes/engines/phptemplate/phptemplate.engine', '1', -1, '0', 'a:11:{s:4:"name";s:7:"Garland";s:11:"description";s:66:"Tableless, recolorable, multi-column, fluid width theme (default).";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:2:{s:3:"all";a:1:{s:9:"style.css";s:24:"themes/garland/style.css";}s:5:"print";a:1:{s:9:"print.css";s:24:"themes/garland/print.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:29:"themes/garland/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}'),
('themes/garland/minnelli/minnelli.info', 'minnelli', 'theme', 'themes/engines/phptemplate/phptemplate.engine', '0', -1, '0', 'a:12:{s:4:"name";s:8:"Minnelli";s:11:"description";s:56:"Tableless, recolorable, multi-column, fixed width theme.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:10:"base theme";s:7:"garland";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:12:"minnelli.css";s:36:"themes/garland/minnelli/minnelli.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:38:"themes/garland/minnelli/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}s:6:"engine";s:11:"phptemplate";}'),
('sites/all/themes/overlay/overlay.info', 'overlay', 'theme', 'themes/engines/phptemplate/phptemplate.engine', '1', -1, '0', 'a:11:{s:4:"name";s:15:"Overlay theming";s:11:"description";s:61:"Very simple overlay theme to resemble d7ux.org mockups later.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:9:"style.css";s:34:"sites/all/themes/overlay/style.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:39:"sites/all/themes/overlay/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}'),
('themes/stark/stark.info', 'stark', 'theme', 'themes/engines/phptemplate/phptemplate.engine', '0', -1, '0', 'a:11:{s:4:"name";s:5:"Stark";s:11:"description";s:229:"This theme demonstrates Drupal''s default HTML markup and CSS styles. To learn how to build your own theme and override Drupal''s default code, you should start reading the <a href="http://drupal.org/theme-guide">Theming Guide</a>.";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:6:"engine";s:11:"phptemplate";s:11:"stylesheets";a:1:{s:3:"all";a:1:{s:10:"layout.css";s:23:"themes/stark/layout.css";}}s:7:"regions";a:8:{s:4:"left";s:12:"Left sidebar";s:5:"right";s:13:"Right sidebar";s:7:"content";s:7:"Content";s:6:"header";s:6:"Header";s:6:"footer";s:6:"Footer";s:9:"highlight";s:19:"Highlighted content";s:4:"help";s:4:"Help";s:8:"page_top";s:8:"Page top";}s:8:"features";a:10:{i:0;s:20:"comment_user_picture";i:1;s:25:"comment_user_verification";i:2;s:7:"favicon";i:3;s:4:"logo";i:4;s:4:"name";i:5;s:17:"node_user_picture";i:6;s:6:"search";i:7;s:6:"slogan";i:8;s:9:"main_menu";i:9;s:14:"secondary_menu";}s:10:"screenshot";s:27:"themes/stark/screenshot.png";s:3:"php";s:5:"5.2.0";s:7:"scripts";a:0:{}}'),
('modules/system/system.module', 'system', 'module', '', '1', 7028, '0', 'a:10:{s:4:"name";s:6:"System";s:11:"description";s:54:"Handles general site configuration for administrators.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:7:{i:0;s:13:"system.module";i:1;s:16:"system.admin.inc";i:2;s:16:"system.queue.inc";i:3;s:12:"image.gd.inc";i:4;s:14:"system.install";i:5;s:11:"system.test";i:6;s:14:"system.tar.inc";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/admin/admin.module', 'admin', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:5:"Admin";s:11:"description";s:101:"Drupal administration UI helpers. Includes: admin menu, contextual administration links, admin theme.";s:7:"package";s:14:"Administration";s:4:"core";s:3:"7.x";s:7:"version";s:7:"7.0-dev";s:5:"files";a:2:{i:0;s:13:"admin.install";i:1;s:12:"admin.module";}s:12:"dependencies";a:1:{i:0;s:4:"menu";}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/aggregator/aggregator.module', 'aggregator', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:10:"Aggregator";s:11:"description";s:57:"Aggregates syndicated content (RSS, RDF, and Atom feeds).";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:8:{i:0;s:17:"aggregator.module";i:1;s:20:"aggregator.admin.inc";i:2;s:20:"aggregator.pages.inc";i:3;s:22:"aggregator.fetcher.inc";i:4;s:21:"aggregator.parser.inc";i:5;s:24:"aggregator.processor.inc";i:6;s:18:"aggregator.install";i:7;s:15:"aggregator.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/aggregator/tests/aggregator_test.module', 'aggregator_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:23:"Aggregator module tests";s:11:"description";s:46:"Support module for aggregator related testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:22:"aggregator_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/block/block.module', 'block', 'module', '', '1', 7000, '-5', 'a:9:{s:4:"name";s:5:"Block";s:11:"description";s:62:"Controls the boxes that are displayed around the main content.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:12:"block.module";i:1;s:15:"block.admin.inc";i:2;s:13:"block.install";i:3;s:10:"block.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/blog/blog.module', 'blog', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:4:"Blog";s:11:"description";s:25:"Enables multi-user blogs.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:11:"blog.module";i:1;s:14:"blog.pages.inc";i:2;s:9:"blog.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/blogapi/blogapi.module', 'blogapi', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:8:"Blog API";s:11:"description";s:79:"Allows users to post content using applications that support XML-RPC blog APIs.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:14:"blogapi.module";i:1;s:15:"blogapi.install";i:2;s:12:"blogapi.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/book/book.module', 'book', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:4:"Book";s:11:"description";s:66:"Allows users to create and organize related content in an outline.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:11:"book.module";i:1;s:14:"book.admin.inc";i:2;s:14:"book.pages.inc";i:3;s:12:"book.install";i:4;s:9:"book.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/color/color.module', 'color', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:5:"Color";s:11:"description";s:70:"Allows administrators to change the color scheme of compatible themes.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:2:{i:0;s:12:"color.module";i:1;s:13:"color.install";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/comment/comment.module', 'comment', 'module', '', '1', 7003, '0', 'a:9:{s:4:"name";s:7:"Comment";s:11:"description";s:57:"Allows users to comment on and discuss published content.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:14:"comment.module";i:1;s:17:"comment.admin.inc";i:2;s:17:"comment.pages.inc";i:3;s:15:"comment.install";i:4;s:12:"comment.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/contact/contact.module', 'contact', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:7:"Contact";s:11:"description";s:61:"Enables the use of both personal and site-wide contact forms.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:14:"contact.module";i:1;s:17:"contact.admin.inc";i:2;s:17:"contact.pages.inc";i:3;s:15:"contact.install";i:4;s:12:"contact.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/d7uxoverlay/d7uxoverlay.module', 'd7uxoverlay', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:17:"D7UX overlay look";s:11:"description";s:38:"D7UX overlay look for modal frame API.";s:7:"package";s:14:"User interface";s:12:"dependencies";a:2:{i:0;s:10:"modalframe";i:1;s:5:"admin";}s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:18:"d7uxoverlay.module";}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/database_test.module', 'database_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:13:"Database Test";s:11:"description";s:40:"Support module for Database layer tests.";s:4:"core";s:3:"7.x";s:7:"package";s:7:"Testing";s:5:"files";a:2:{i:0;s:20:"database_test.module";i:1;s:21:"database_test.install";}s:7:"version";s:7:"7.0-dev";s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/dblog/dblog.module', 'dblog', 'module', '', '1', 7003, '0', 'a:9:{s:4:"name";s:16:"Database logging";s:11:"description";s:47:"Logs and records system events to the database.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:12:"dblog.module";i:1;s:15:"dblog.admin.inc";i:2;s:13:"dblog.install";i:3;s:10:"dblog.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/error_test.module', 'error_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:10:"Error test";s:11:"description";s:47:"Support module for error and exception testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:17:"error_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/field.module', 'field', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:5:"Field";s:11:"description";s:56:"Field API to add fields to objects like nodes and users.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:8:{i:0;s:12:"field.module";i:1;s:13:"field.install";i:2;s:14:"field.crud.inc";i:3;s:14:"field.info.inc";i:4;s:17:"field.default.inc";i:5;s:16:"field.attach.inc";i:6;s:14:"field.form.inc";i:7;s:10:"field.test";}s:12:"dependencies";a:1:{i:0;s:17:"field_sql_storage";}s:8:"required";b:1;s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/modules/field_sql_storage/field_sql_storage.module', 'field_sql_storage', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:17:"Field SQL storage";s:11:"description";s:37:"Stores field data in an SQL database.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:24:"field_sql_storage.module";i:1;s:25:"field_sql_storage.install";i:2;s:22:"field_sql_storage.test";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/field_test.module', 'field_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:14:"Field API Test";s:11:"description";s:39:"Support module for the Field API tests.";s:4:"core";s:3:"7.x";s:7:"package";s:7:"Testing";s:5:"files";a:2:{i:0;s:17:"field_test.module";i:1;s:18:"field_test.install";}s:7:"version";s:7:"7.0-dev";s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/file_test.module', 'file_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:9:"File test";s:11:"description";s:39:"Support module for file handling tests.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:16:"file_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/filter/filter.module', 'filter', 'module', '', '1', 7002, '0', 'a:10:{s:4:"name";s:6:"Filter";s:11:"description";s:43:"Filters content in preparation for display.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:13:"filter.module";i:1;s:16:"filter.admin.inc";i:2;s:16:"filter.pages.inc";i:3;s:14:"filter.install";i:4;s:11:"filter.test";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/form_test.module', 'form_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:12:"FormAPI Test";s:11:"description";s:34:"Support module for Form API tests.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:16:"form_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/forum/forum.module', 'forum', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:5:"Forum";s:11:"description";s:27:"Provides discussion forums.";s:12:"dependencies";a:2:{i:0;s:8:"taxonomy";i:1;s:7:"comment";}s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:12:"forum.module";i:1;s:15:"forum.admin.inc";i:2;s:15:"forum.pages.inc";i:3;s:13:"forum.install";i:4;s:10:"forum.test";}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/help/help.module', 'help', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:4:"Help";s:11:"description";s:35:"Manages the display of online help.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:11:"help.module";i:1;s:14:"help.admin.inc";i:2;s:9:"help.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/image_test.module', 'image_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:10:"Image test";s:11:"description";s:39:"Support module for image toolkit tests.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:17:"image_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/modules/list/list.module', 'list', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:4:"List";s:11:"description";s:69:"Defines list field types. Use with Options to create selection lists.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:11:"list.module";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/locale/locale.module', 'locale', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:6:"Locale";s:11:"description";s:119:"Adds language handling functionality and enables the translation of the user interface to languages other than English.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:13:"locale.module";i:1;s:14:"locale.install";i:2;s:11:"locale.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/locale/tests/locale_test.module', 'locale_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:11:"Locale Test";s:11:"description";s:42:"Support module for the locale layer tests.";s:4:"core";s:3:"7.x";s:7:"package";s:7:"Testing";s:5:"files";a:1:{i:0;s:18:"locale_test.module";}s:7:"version";s:7:"7.0-dev";s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/menu/menu.module', 'menu', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:4:"Menu";s:11:"description";s:60:"Allows administrators to customize the site navigation menu.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:11:"menu.module";i:1;s:14:"menu.admin.inc";i:2;s:12:"menu.install";i:3;s:9:"menu.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/menu_test.module', 'menu_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:15:"Hook menu tests";s:11:"description";s:37:"Support module for menu hook testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:16:"menu_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/modalframe/modalframe.module', 'modalframe', 'module', '', '1', 0, '0', 'a:9:{s:4:"name";s:15:"Modal Frame API";s:11:"description";s:95:"Provides an API to render an iframe within a modal dialog based on the jQuery UI Dialog plugin.";s:7:"package";s:14:"User interface";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:17:"modalframe.module";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('modules/node/node.module', 'node', 'module', '', '1', 7005, '0', 'a:10:{s:4:"name";s:4:"Node";s:11:"description";s:66:"Allows content to be submitted to the site and displayed on pages.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:6:{i:0;s:11:"node.module";i:1;s:17:"content_types.inc";i:2;s:14:"node.admin.inc";i:3;s:14:"node.pages.inc";i:4;s:12:"node.install";i:5;s:9:"node.test";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/node/tests/node_test.module', 'node_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:17:"Node module tests";s:11:"description";s:40:"Support module for node related testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:16:"node_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/modules/number/number.module', 'number', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:6:"Number";s:11:"description";s:28:"Defines numeric field types.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:13:"number.module";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/openid/openid.module', 'openid', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:6:"OpenID";s:11:"description";s:48:"Allows users to log into your site using OpenID.";s:7:"version";s:7:"7.0-dev";s:7:"package";s:4:"Core";s:4:"core";s:3:"7.x";s:5:"files";a:6:{i:0;s:13:"openid.module";i:1;s:10:"openid.inc";i:2;s:16:"openid.pages.inc";i:3;s:8:"xrds.inc";i:4;s:14:"openid.install";i:5;s:11:"openid.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/openid/tests/openid_test.module', 'openid_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:21:"OpenID dummy provider";s:11:"description";s:33:"OpenID provider used for testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:2:{i:0;s:19:"openid_test.install";i:1;s:18:"openid_test.module";}s:12:"dependencies";a:1:{i:0;s:6:"openid";}s:6:"hidden";b:1;s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/modules/options/options.module', 'options', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:7:"Options";s:11:"description";s:82:"Defines selection, check box and radio button widgets for text and numeric fields.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:14:"options.module";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/path/path.module', 'path', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:4:"Path";s:11:"description";s:28:"Allows users to rename URLs.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:11:"path.module";i:1;s:14:"path.admin.inc";i:2;s:9:"path.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/php/php.module', 'php', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:10:"PHP filter";s:11:"description";s:50:"Allows embedded PHP code/snippets to be evaluated.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:10:"php.module";i:1;s:11:"php.install";i:2;s:8:"php.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/poll/poll.module', 'poll', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:4:"Poll";s:11:"description";s:95:"Allows your site to capture votes on different topics in the form of multiple choice questions.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:11:"poll.module";i:1;s:14:"poll.pages.inc";i:2;s:12:"poll.install";i:3;s:9:"poll.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/popups/popups.module', 'popups', 'module', '', '1', 0, '9999', 'a:9:{s:4:"name";s:10:"Popups API";s:11:"description";s:33:"General dialog creation utilities";s:7:"package";s:14:"User interface";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:13:"popups.module";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/popups/popups_admin.module', 'popups_admin', 'module', '', '0', 0, '0', 'a:9:{s:4:"name";s:28:"Popups: Administration Links";s:11:"description";s:66:"Uses the Popups API to add popups to various administration pages.";s:7:"package";s:14:"User interface";s:4:"core";s:3:"7.x";s:12:"dependencies";a:1:{i:0;s:6:"popups";}s:5:"files";a:1:{i:0;s:19:"popups_admin.module";}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/popups/popups_test.module', 'popups_test', 'module', '', '0', 0, '0', 'a:9:{s:4:"name";s:17:"Popups: Test Page";s:11:"description";s:20:"Test the Popups API.";s:7:"package";s:14:"User interface";s:4:"core";s:3:"7.x";s:12:"dependencies";a:1:{i:0;s:6:"popups";}s:5:"files";a:1:{i:0;s:18:"popups_test.module";}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('modules/profile/profile.module', 'profile', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:7:"Profile";s:11:"description";s:36:"Supports configurable user profiles.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:14:"profile.module";i:1;s:17:"profile.admin.inc";i:2;s:17:"profile.pages.inc";i:3;s:15:"profile.install";i:4;s:12:"profile.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/search/search.module', 'search', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:6:"Search";s:11:"description";s:36:"Enables site-wide keyword searching.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:13:"search.module";i:1;s:16:"search.admin.inc";i:2;s:16:"search.pages.inc";i:3;s:14:"search.install";i:4;s:11:"search.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/session_test.module', 'session_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:12:"Session test";s:11:"description";s:40:"Support module for session data testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:19:"session_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/simpletest.module', 'simpletest', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:10:"SimpleTest";s:11:"description";s:53:"Provides a framework for unit and functional testing.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:24:{i:0;s:17:"simpletest.module";i:1;s:20:"simpletest.pages.inc";i:2;s:18:"simpletest.install";i:3;s:15:"simpletest.test";i:4;s:24:"drupal_web_test_case.php";i:5;s:18:"tests/actions.test";i:6;s:16:"tests/batch.test";i:7;s:20:"tests/bootstrap.test";i:8;s:16:"tests/cache.test";i:9;s:17:"tests/common.test";i:10;s:24:"tests/database_test.test";i:11;s:16:"tests/error.test";i:12;s:15:"tests/file.test";i:13;s:15:"tests/form.test";i:14;s:16:"tests/graph.test";i:15;s:16:"tests/image.test";i:16;s:15:"tests/menu.test";i:17;s:17:"tests/module.test";i:18;s:19:"tests/registry.test";i:19;s:17:"tests/schema.test";i:20;s:18:"tests/session.test";i:21;s:16:"tests/theme.test";i:22;s:18:"tests/unicode.test";i:23;s:17:"tests/xmlrpc.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/statistics/statistics.module', 'statistics', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:10:"Statistics";s:11:"description";s:37:"Logs access statistics for your site.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:17:"statistics.module";i:1;s:20:"statistics.admin.inc";i:2;s:20:"statistics.pages.inc";i:3;s:18:"statistics.install";i:4;s:15:"statistics.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/syslog/syslog.module', 'syslog', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:6:"Syslog";s:11:"description";s:41:"Logs and records system events to syslog.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:2:{i:0;s:13:"syslog.module";i:1;s:11:"syslog.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/system_test.module', 'system_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:11:"System test";s:11:"description";s:34:"Support module for system testing.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:18:"system_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/taxonomy/taxonomy.module', 'taxonomy', 'module', '', '1', 7002, '0', 'a:9:{s:4:"name";s:8:"Taxonomy";s:11:"description";s:38:"Enables the categorization of content.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:15:"taxonomy.module";i:1;s:18:"taxonomy.admin.inc";i:2;s:18:"taxonomy.pages.inc";i:3;s:16:"taxonomy.install";i:4;s:13:"taxonomy.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/taxonomy_test.module', 'taxonomy_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:20:"Taxonomy test module";s:11:"description";s:45:""Tests functions and hooks not used in core".";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:20:"taxonomy_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:1:{i:0;s:8:"taxonomy";}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/field/modules/text/text.module', 'text', 'module', '', '1', 0, '0', 'a:10:{s:4:"name";s:4:"Text";s:11:"description";s:32:"Defines simple text field types.";s:7:"package";s:13:"Core - fields";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:2:{i:0;s:11:"text.module";i:1;s:9:"text.test";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/tracker/tracker.module', 'tracker', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:7:"Tracker";s:11:"description";s:43:"Enables tracking of recent posts for users.";s:12:"dependencies";a:1:{i:0;s:7:"comment";}s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:14:"tracker.module";i:1;s:17:"tracker.pages.inc";i:2;s:12:"tracker.test";}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/translation/translation.module', 'translation', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:19:"Content translation";s:11:"description";s:57:"Allows content to be translated into different languages.";s:12:"dependencies";a:1:{i:0;s:6:"locale";}s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:18:"translation.module";i:1;s:21:"translation.pages.inc";i:2;s:16:"translation.test";}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/trigger/trigger.module', 'trigger', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:7:"Trigger";s:11:"description";s:90:"Enables actions to be fired on certain system events, such as when new content is created.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:14:"trigger.module";i:1;s:17:"trigger.admin.inc";i:2;s:15:"trigger.install";i:3;s:12:"trigger.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/trigger/tests/trigger_test.module', 'trigger_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:12:"Trigger Test";s:11:"description";s:33:"Support module for Trigger tests.";s:7:"package";s:7:"Testing";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:19:"trigger_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('modules/update/update.module', 'update', 'module', '', '1', 6000, '0', 'a:9:{s:4:"name";s:13:"Update status";s:11:"description";s:88:"Checks the status of available updates for Drupal and your installed modules and themes.";s:7:"version";s:7:"7.0-dev";s:7:"package";s:4:"Core";s:4:"core";s:3:"7.x";s:5:"files";a:6:{i:0;s:13:"update.module";i:1;s:18:"update.compare.inc";i:2;s:16:"update.fetch.inc";i:3;s:17:"update.report.inc";i:4;s:19:"update.settings.inc";i:5;s:14:"update.install";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/upload/upload.module', 'upload', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:6:"Upload";s:11:"description";s:51:"Allows users to upload and attach files to content.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:4:{i:0;s:13:"upload.module";i:1;s:16:"upload.admin.inc";i:2;s:14:"upload.install";i:3;s:11:"upload.test";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/user/user.module', 'user', 'module', '', '1', 7004, '0', 'a:10:{s:4:"name";s:4:"User";s:11:"description";s:47:"Manages the user registration and login system.";s:7:"package";s:4:"Core";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:5:{i:0;s:11:"user.module";i:1;s:14:"user.admin.inc";i:2;s:14:"user.pages.inc";i:3;s:12:"user.install";i:4;s:9:"user.test";}s:8:"required";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('modules/simpletest/tests/xmlrpc_test.module', 'xmlrpc_test', 'module', '', '0', -1, '0', 'a:10:{s:4:"name";s:12:"XML-RPC Test";s:11:"description";s:75:"Support module for XML-RPC tests according to the validator1 specification.";s:7:"package";s:7:"Testing";s:7:"version";s:7:"7.0-dev";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:18:"xmlrpc_test.module";}s:6:"hidden";b:1;s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/demo/demo.module', 'demo', 'module', '', '1', 6100, '0', 'a:9:{s:4:"name";s:9:"Demo Site";s:11:"description";s:74:"Create snapshots and reset the site for demonstration or testing purposes.";s:7:"package";s:11:"Development";s:4:"core";s:3:"7.x";s:5:"files";a:3:{i:0;s:11:"demo.module";i:1;s:14:"demo.admin.inc";i:2;s:23:"database_mysql_dump.inc";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/form_builder/form_builder.module', 'form_builder', 'module', '', '0', -1, '0', 'a:9:{s:4:"name";s:12:"Form builder";s:11:"description";s:24:"Form building framework.";s:12:"dependencies";a:1:{i:0;s:15:"options_element";}s:4:"core";s:3:"7.x";s:5:"files";a:11:{i:0;s:19:"form_builder.module";i:1;s:31:"includes/form_builder.cache.inc";i:2;s:31:"includes/form_builder.admin.inc";i:3;s:36:"includes/form_builder.properties.inc";i:4;s:29:"includes/form_builder.api.inc";i:5;s:16:"modules/node.inc";i:6;s:16:"modules/menu.inc";i:7;s:16:"modules/path.inc";i:8;s:16:"modules/poll.inc";i:9;s:20:"modules/taxonomy.inc";i:10;s:18:"modules/upload.inc";}s:10:"dependents";a:0:{}s:7:"package";s:5:"Other";s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/form_builder/examples/form_builder_examples.module', 'form_builder_examples', 'module', '', '0', 0, '0', 'a:9:{s:4:"name";s:21:"Form builder examples";s:11:"description";s:59:"Form builder support for CCK, Webform, and Profile modules.";s:4:"core";s:3:"7.x";s:12:"dependencies";a:1:{i:0;s:12:"form_builder";}s:5:"files";a:1:{i:0;s:28:"form_builder_examples.module";}s:10:"dependents";a:0:{}s:7:"package";s:5:"Other";s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/form_builder/modules/node/form_builder_node.module', 'form_builder_node', 'module', '', '0', -1, '101', 'a:9:{s:4:"name";s:20:"Form builder Node UI";s:11:"description";s:42:"Form builder enhancements for node module.";s:4:"core";s:3:"7.x";s:12:"dependencies";a:1:{i:0;s:12:"form_builder";}s:5:"files";a:2:{i:0;s:25:"form_builder_node.install";i:1;s:24:"form_builder_node.module";}s:10:"dependents";a:0:{}s:7:"package";s:5:"Other";s:7:"version";N;s:3:"php";s:5:"5.2.0";}'),
('sites/all/modules/form_builder/options_element/options_element.module', 'options_element', 'module', '', '0', 0, '0', 'a:9:{s:4:"name";s:15:"Options element";s:11:"description";s:86:"A custom form element for entering the options in select lists, radios, or checkboxes.";s:4:"core";s:3:"7.x";s:5:"files";a:1:{i:0;s:22:"options_element.module";}s:12:"dependencies";a:0:{}s:10:"dependents";a:0:{}s:7:"package";s:5:"Other";s:7:"version";N;s:3:"php";s:5:"5.2.0";}');
/*!40000 ALTER TABLE system ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_term_data'
--

CREATE TABLE IF NOT EXISTS `taxonomy_term_data` (
  `tid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique term ID.',
  `vid` int(10) unsigned NOT NULL default '0' COMMENT 'The taxonomy_vocabulary.vid of the vocabulary to which the term is assigned.',
  `name` varchar(255) NOT NULL default '' COMMENT 'The term name.',
  `description` longtext COMMENT 'A description of the term.',
  `weight` tinyint(4) NOT NULL default '0' COMMENT 'The weight of this term in relation to other terms.',
  PRIMARY KEY  (`tid`),
  KEY `taxonomy_tree` (`vid`,`weight`,`name`),
  KEY `vid_name` (`vid`,`name`)
);

--
-- Dumping data for table 'taxonomy_term_data'
--

/*!40000 ALTER TABLE taxonomy_term_data DISABLE KEYS */;
/*!40000 ALTER TABLE taxonomy_term_data ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_term_hierarchy'
--

CREATE TABLE IF NOT EXISTS `taxonomy_term_hierarchy` (
  `tid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: The taxonomy_term_data.tid of the term.',
  `parent` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: The taxonomy_term_data.tid of the term’s parent. 0 indicates no parent.',
  PRIMARY KEY  (`tid`,`parent`),
  KEY `parent` (`parent`)
);

--
-- Dumping data for table 'taxonomy_term_hierarchy'
--

/*!40000 ALTER TABLE taxonomy_term_hierarchy DISABLE KEYS */;
/*!40000 ALTER TABLE taxonomy_term_hierarchy ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_term_node'
--

CREATE TABLE IF NOT EXISTS `taxonomy_term_node` (
  `nid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: The node.nid of the node.',
  `vid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: The node.vid of the node.',
  `tid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: The taxonomy_term_data.tid of a term assigned to the node.',
  PRIMARY KEY  (`tid`,`vid`),
  KEY `vid` (`vid`),
  KEY `nid` (`nid`)
);

--
-- Dumping data for table 'taxonomy_term_node'
--

/*!40000 ALTER TABLE taxonomy_term_node DISABLE KEYS */;
/*!40000 ALTER TABLE taxonomy_term_node ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_term_relation'
--

CREATE TABLE IF NOT EXISTS `taxonomy_term_relation` (
  `trid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique term relation ID.',
  `tid1` int(10) unsigned NOT NULL default '0' COMMENT 'The taxonomy_term_data.tid of the first term in a relationship.',
  `tid2` int(10) unsigned NOT NULL default '0' COMMENT 'The taxonomy_term_data.tid of the second term in a relationship.',
  PRIMARY KEY  (`trid`),
  UNIQUE KEY `tid1_tid2` (`tid1`,`tid2`),
  KEY `tid2` (`tid2`)
);

--
-- Dumping data for table 'taxonomy_term_relation'
--

/*!40000 ALTER TABLE taxonomy_term_relation DISABLE KEYS */;
/*!40000 ALTER TABLE taxonomy_term_relation ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_term_synonym'
--

CREATE TABLE IF NOT EXISTS `taxonomy_term_synonym` (
  `tsid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique term synonym ID.',
  `tid` int(10) unsigned NOT NULL default '0' COMMENT 'The taxonomy_term_data.tid of the term.',
  `name` varchar(255) NOT NULL default '' COMMENT 'The name of the synonym.',
  PRIMARY KEY  (`tsid`),
  KEY `tid` (`tid`),
  KEY `name_tid` (`name`,`tid`)
);

--
-- Dumping data for table 'taxonomy_term_synonym'
--

/*!40000 ALTER TABLE taxonomy_term_synonym DISABLE KEYS */;
/*!40000 ALTER TABLE taxonomy_term_synonym ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_vocabulary'
--

CREATE TABLE IF NOT EXISTS `taxonomy_vocabulary` (
  `vid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique vocabulary ID.',
  `name` varchar(255) NOT NULL default '' COMMENT 'Name of the vocabulary.',
  `machine_name` varchar(255) NOT NULL default '' COMMENT 'The vocabulary machine name.',
  `description` longtext COMMENT 'Description of the vocabulary.',
  `help` varchar(255) NOT NULL default '' COMMENT 'Help text to display for the vocabulary.',
  `relations` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Whether or not related terms are enabled within the vocabulary. (0 = disabled, 1 = enabled)',
  `hierarchy` tinyint(3) unsigned NOT NULL default '0' COMMENT 'The type of hierarchy allowed within the vocabulary. (0 = disabled, 1 = single, 2 = multiple)',
  `multiple` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Whether or not multiple terms from this vocabulary may be assigned to a node. (0 = disabled, 1 = enabled)',
  `required` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Whether or not terms are required for nodes using this vocabulary. (0 = disabled, 1 = enabled)',
  `tags` tinyint(3) unsigned NOT NULL default '0' COMMENT 'Whether or not free tagging is enabled for the vocabulary. (0 = disabled, 1 = enabled)',
  `module` varchar(255) NOT NULL default '' COMMENT 'The module which created the vocabulary.',
  `weight` tinyint(4) NOT NULL default '0' COMMENT 'The weight of the vocabulary in relation to other vocabularies.',
  PRIMARY KEY  (`vid`),
  KEY `list` (`weight`,`name`)
);

--
-- Dumping data for table 'taxonomy_vocabulary'
--

/*!40000 ALTER TABLE taxonomy_vocabulary DISABLE KEYS */;
INSERT INTO `taxonomy_vocabulary` VALUES
('1', 'Tags', '', 'Use tags to group articles on similar topics into categories.', 'Enter a comma-separated list of words.', '0', '0', '0', '0', '1', 'taxonomy', '0');
/*!40000 ALTER TABLE taxonomy_vocabulary ENABLE KEYS */;

--
-- Table structure for table 'taxonomy_vocabulary_node_type'
--

CREATE TABLE IF NOT EXISTS `taxonomy_vocabulary_node_type` (
  `vid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: the taxonomy_vocabulary.vid of the vocabulary.',
  `type` varchar(32) NOT NULL default '' COMMENT 'The node.type of the node type for which the vocabulary may be used.',
  PRIMARY KEY  (`type`,`vid`),
  KEY `vid` (`vid`)
);

--
-- Dumping data for table 'taxonomy_vocabulary_node_type'
--

/*!40000 ALTER TABLE taxonomy_vocabulary_node_type DISABLE KEYS */;
INSERT INTO `taxonomy_vocabulary_node_type` VALUES
('1', 'article');
/*!40000 ALTER TABLE taxonomy_vocabulary_node_type ENABLE KEYS */;

--
-- Table structure for table 'url_alias'
--

CREATE TABLE IF NOT EXISTS `url_alias` (
  `pid` int(10) unsigned NOT NULL auto_increment COMMENT 'A unique path alias identifier.',
  `src` varchar(255) NOT NULL default '' COMMENT 'The Drupal path this alias is for; e.g. node/12.',
  `dst` varchar(255) NOT NULL default '' COMMENT 'The alias for this path; e.g. title-of-the-story.',
  `language` varchar(12) NOT NULL default '' COMMENT 'The language this alias is for; if blank, the alias will be used for unknown languages. Each Drupal path can have an alias for each supported language.',
  PRIMARY KEY  (`pid`),
  UNIQUE KEY `dst_language_pid` (`dst`,`language`,`pid`),
  KEY `src_language_pid` (`src`,`language`,`pid`)
);

--
-- Dumping data for table 'url_alias'
--

/*!40000 ALTER TABLE url_alias DISABLE KEYS */;
/*!40000 ALTER TABLE url_alias ENABLE KEYS */;

--
-- Table structure for table 'users'
--

CREATE TABLE IF NOT EXISTS `users` (
  `uid` int(10) unsigned NOT NULL auto_increment COMMENT 'Primary Key: Unique user ID.',
  `name` varchar(60) NOT NULL default '' COMMENT 'Unique user name.',
  `pass` varchar(128) NOT NULL default '' COMMENT 'User’s password (hashed).',
  `mail` varchar(64) default '' COMMENT 'User’s email address.',
  `theme` varchar(255) NOT NULL default '' COMMENT 'User’s default theme.',
  `signature` varchar(255) NOT NULL default '' COMMENT 'User’s signature.',
  `created` int(11) NOT NULL default '0' COMMENT 'Timestamp for when user was created.',
  `access` int(11) NOT NULL default '0' COMMENT 'Timestamp for previous time user accessed the site.',
  `login` int(11) NOT NULL default '0' COMMENT 'Timestamp for user’s last login.',
  `status` tinyint(4) NOT NULL default '0' COMMENT 'Whether the user is active(1) or blocked(0).',
  `timezone` varchar(32) default NULL COMMENT 'User’s time zone.',
  `language` varchar(12) NOT NULL default '' COMMENT 'User’s default language.',
  `picture` int(11) NOT NULL default '0' COMMENT 'Foreign key: files.fid of user’s picture.',
  `init` varchar(64) default '' COMMENT 'Email address used for initial account creation.',
  `data` longtext COMMENT 'A serialized array of name value pairs that are related to the user. Any form values posted during user edit are stored and are loaded into the $user object during user_load(). Use of this field is discouraged and it will likely disappear in a future ...',
  PRIMARY KEY  (`uid`),
  UNIQUE KEY `name` (`name`),
  KEY `access` (`access`),
  KEY `created` (`created`),
  KEY `mail` (`mail`)
);

--
-- Dumping data for table 'users'
--

/*!40000 ALTER TABLE users DISABLE KEYS */;
INSERT INTO `users` VALUES
('0', '', '', '', '', '', '0', '0', '0', '0', NULL, '', '0', '', NULL),
('1', 'admin', '$P$CEpIGl5eiXMwrrmZFf4iS1.FGIn.TW1', 'admin@admin.admin', '', '', '1245678273', '1246392247', '1246384522', '1', 'America/New_York', '', '0', 'admin@admin.admin', '');
/*!40000 ALTER TABLE users ENABLE KEYS */;

--
-- Table structure for table 'users_roles'
--

CREATE TABLE IF NOT EXISTS `users_roles` (
  `uid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: users.uid for user.',
  `rid` int(10) unsigned NOT NULL default '0' COMMENT 'Primary Key: role.rid for role.',
  PRIMARY KEY  (`uid`,`rid`),
  KEY `rid` (`rid`)
);

--
-- Dumping data for table 'users_roles'
--

/*!40000 ALTER TABLE users_roles DISABLE KEYS */;
/*!40000 ALTER TABLE users_roles ENABLE KEYS */;

--
-- Table structure for table 'variable'
--

CREATE TABLE IF NOT EXISTS `variable` (
  `name` varchar(128) NOT NULL default '' COMMENT 'The name of the variable.',
  `value` longtext NOT NULL COMMENT 'The value of the variable.',
  PRIMARY KEY  (`name`)
);

--
-- Dumping data for table 'variable'
--

/*!40000 ALTER TABLE variable DISABLE KEYS */;
INSERT INTO `variable` VALUES
('theme_default', 's:7:"garland";'),
('filter_html_1', 'i:1;'),
('node_options_forum', 'a:1:{i:0;s:6:"status";}'),
('cron_key', 's:32:"5c8e21a687a8677a80658b0f2d7a542c";'),
('path_alias_whitelist', 'a:0:{}'),
('drupal_private_key', 's:32:"9c8ef1846ff79be7b74869a580bba678";'),
('menu_masks', 'a:17:{i:0;i:61;i:1;i:44;i:2;i:31;i:3;i:30;i:4;i:29;i:5;i:24;i:6;i:21;i:7;i:15;i:8;i:14;i:9;i:13;i:10;i:11;i:11;i:7;i:12;i:6;i:13;i:5;i:14;i:3;i:15;i:2;i:16;i:1;}'),
('cron_last', 'i:1245678388;'),
('install_task', 's:4:"done";'),
('menu_expanded', 'a:0:{}'),
('site_name', 's:14:"D7UX Demo Site";'),
('site_mail', 's:17:"admin@admin.admin";'),
('date_default_timezone', 's:16:"America/New_York";'),
('site_default_country', 's:0:"";'),
('user_email_verification', 'i:1;'),
('field_sql_storage_user_etid', 's:1:"1";'),
('clean_url', 'i:0;'),
('install_time', 'i:1245678388;'),
('node_options_page', 'a:1:{i:0;s:6:"status";}'),
('comment_page', 'i:0;'),
('node_submitted_page', 'b:0;'),
('drupal_http_request_fails', 'b:0;'),
('popups_always_scan', 'i:1;'),
('popups_skin', 's:4:"D7ux";'),
('css_js_query_string', 's:20:"S5000000000000000000";'),
('install_profile', 's:4:"d7ux";'),
('update_last_check', 'i:1245678388;'),
('javascript_parsed', 'a:0:{}'),
('admin_theme', 's:1:"0";'),
('node_admin_theme', 'i:0;'),
('demo_dump_path', 's:24:"sites/default/files/demo";'),
('demo_reset_interval', 's:5:"10800";'),
('demo_dump_cron', 's:7:"Default";'),
('anonymous', 's:9:"Anonymous";'),
('user_admin_role', 's:1:"0";'),
('user_register', 's:1:"0";');
/*!40000 ALTER TABLE variable ENABLE KEYS */;

--
-- Table structure for table 'watchdog'
--

CREATE TABLE IF NOT EXISTS `watchdog` (
  `wid` int(11) NOT NULL auto_increment COMMENT 'Primary Key: Unique watchdog event ID.',
  `uid` int(11) NOT NULL default '0' COMMENT 'The users.uid of the user who triggered the event.',
  `type` varchar(64) NOT NULL default '' COMMENT 'Type of log message, for example `user` or `page not found.`',
  `message` longtext NOT NULL COMMENT 'Text of log message to be passed into the t() function.',
  `variables` longtext NOT NULL COMMENT 'Serialized array of variables that match the message string and that is passed into the t() function.',
  `severity` tinyint(3) unsigned NOT NULL default '0' COMMENT 'The severity level of the event; ranges from 0 (Emergency) to 7 (Debug)',
  `link` varchar(255) default '' COMMENT 'Link to view the result of the event.',
  `location` text NOT NULL COMMENT 'URL of the origin of the event.',
  `referer` text COMMENT 'URL of referring page.',
  `hostname` varchar(128) NOT NULL default '' COMMENT 'Hostname of the user who triggered the event.',
  `timestamp` int(11) NOT NULL default '0' COMMENT 'Unix timestamp of when event occurred.',
  PRIMARY KEY  (`wid`),
  KEY `type` (`type`),
  KEY `uid` (`uid`)
);

SET FOREIGN_KEY_CHECKS = 1;
