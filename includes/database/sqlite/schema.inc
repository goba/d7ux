<?php
// $Id: schema.inc,v 1.9 2009/08/22 19:43:12 webchick Exp $

/**
 * @file
 * Database schema code for SQLite databases.
 */


/**
 * @ingroup schemaapi
 * @{
 */

class DatabaseSchema_sqlite extends DatabaseSchema {

  public function tableExists($table) {
    // Don't use {} around sqlite_master table.
    return (bool) $this->connection->query("SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE '{" . $table . "}'", array(), array())->fetchField();
  }

  public function columnExists($table, $column) {
    $schema = $this->introspectSchema($table);
    return !empty($schema['fields'][$column]);
  }

  /**
   * Generate SQL to create a new table from a Drupal schema definition.
   *
   * @param $name
   *   The name of the table to create.
   * @param $table
   *   A Schema API table definition array.
   * @return
   *   An array of SQL statements to create the table.
   */
  public function createTableSql($name, $table) {
    $sql = array();
    $sql[] = "CREATE TABLE {" . $name . "} (\n" . $this->createColumsSql($name, $table) . "\n);\n";
    return array_merge($sql, $this->createIndexSql($name, $table));
  }

  /**
   * Build the SQL expression for indexes.
   */
  protected function createIndexSql($tablename, $schema) {
    $sql = array();
    if (!empty($schema['unique keys'])) {
      foreach ($schema['unique keys'] as $key => $fields) {
        $sql[] = 'CREATE UNIQUE INDEX "{' . $tablename . '}_' . $key . '" ON {' . $tablename . '} (' . $this->createKeySql($fields) . "); \n";
      }
    }
    if (!empty($schema['indexes'])) {
      foreach ($schema['indexes'] as $index => $fields) {
        $sql[] = 'CREATE INDEX "{' . $tablename . '}_' . $index . '" ON {' . $tablename . '} (' . $this->createKeySql($fields) . "); \n";
      }
    }
    return $sql;
  }

  /**
   * Build the SQL expression for creating columns.
   */
  protected function createColumsSql($tablename, $schema) {
    $sql_array = array();

    // Add the SQL statement for each field.
    foreach ($schema['fields'] as $name => $field) {
      if ($field['type'] == 'serial') {
        if (isset($schema['primary key']) && ($key = array_search($name, $schema['primary key'])) !== FALSE) {
          unset($schema['primary key'][$key]);
        }
      }
      $sql_array[] = $this->createFieldSql($name, $this->processField($field));
    }

    // Process keys.
    if (!empty($schema['primary key'])) {
      $sql_array[] = " PRIMARY KEY (" . $this->createKeySql($schema['primary key']) . ")";
    }

    return implode(", \n", $sql_array);
  }

  /**
   * Build the SQL expression for keys.
   */
  protected function createKeySql($fields) {
    $ret = array();
    foreach ($fields as $field) {
      if (is_array($field)) {
        $ret[] = $field[0];
      }
      else {
        $ret[] = $field;
      }
    }
    return implode(', ', $ret);
  }

  /**
   * Set database-engine specific properties for a field.
   *
   * @param $field
   *   A field description array, as specified in the schema documentation.
   */
  protected function processField($field) {
    if (!isset($field['size'])) {
      $field['size'] = 'normal';
    }
    // Set the correct database-engine specific datatype.
    if (!isset($field['sqlite_type'])) {
      $map = $this->getFieldTypeMap();
      $field['sqlite_type'] = $map[$field['type'] . ':' . $field['size']];
    }

    if ($field['type'] == 'serial') {
      $field['auto_increment'] = TRUE;
    }

    return $field;
  }

  /**
  * Create an SQL string for a field to be used in table creation or alteration.
  *
  * Before passing a field out of a schema definition into this function it has
  * to be processed by db_processField().
  *
  * @param $name
  *    Name of the field.
  * @param $spec
  *    The field specification, as per the schema data structure format.
  */
  protected function createFieldSql($name, $spec) {
    if (!empty($spec['auto_increment'])) {
      $sql = $name . " INTEGER PRIMARY KEY AUTOINCREMENT";
    }
    else {
      $sql = $name . " " . $spec['sqlite_type'];

      if (in_array($spec['type'], array('varchar', 'char', 'text')) && isset($spec['length'])) {
        $sql .= '(' . $spec['length'] . ')';
      }

      if (!empty($spec['not null'])) {
        $sql .= ' NOT NULL';
      }

      if (isset($spec['default'])) {
        if (is_string($spec['default'])) {
          $spec['default'] = "'" . $spec['default'] . "'";
        }
        $sql .= ' DEFAULT ' . $spec['default'];
      }

      if (empty($spec['not null']) && !isset($spec['default'])) {
        $sql .= ' DEFAULT NULL';
      }
    }
    return $sql;
  }

  /**
   * This maps a generic data type in combination with its data size
   * to the engine-specific data type.
   */
  public function getFieldTypeMap() {
    // Put :normal last so it gets preserved by array_flip. This makes
    // it much easier for modules (such as schema.module) to map
    // database types back into schema types.
    // $map does not use drupal_static as its value never changes.
    static $map = array(
      'varchar:normal'  => 'VARCHAR',

      'text:tiny'       => 'TEXT',
      'text:small'      => 'TEXT',
      'text:medium'     => 'TEXT',
      'text:big'        => 'TEXT',
      'text:normal'     => 'TEXT',

      'serial:tiny'     => 'INTEGER',
      'serial:small'    => 'INTEGER',
      'serial:medium'   => 'INTEGER',
      'serial:big'      => 'INTEGER',
      'serial:normal'   => 'INTEGER',

      'int:tiny'        => 'INTEGER',
      'int:small'       => 'INTEGER',
      'int:medium'      => 'INTEGER',
      'int:big'         => 'INTEGER',
      'int:normal'      => 'INTEGER',

      'float:tiny'      => 'FLOAT',
      'float:small'     => 'FLOAT',
      'float:medium'    => 'FLOAT',
      'float:big'       => 'FLOAT',
      'float:normal'    => 'FLOAT',

      'numeric:normal'  => 'NUMERIC',

      'blob:big'        => 'BLOB',
      'blob:normal'     => 'BLOB',

      'date:normal'     => 'DATE',

      'time:normal'   => 'TIME',

      'datetime:normal' => 'TIMESTAMP',
    );
    return $map;
  }

  /**
  * Rename a table.
  *
  * @param $ret
  *   Array to which query results will be added.
  * @param $table
  *   The table to be renamed.
  * @param $new_name
  *   The new name for the table.
  */
  public function renameTable(&$ret, $table, $new_name) {
    $ret[] = update_sql('ALTER TABLE {' . $table . '} RENAME TO {' . $new_name . '}');
  }

  /**
   * Drop a table.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be dropped.
   */
  public function dropTable(&$ret, $table) {
    $ret[] = update_sql('DROP TABLE {' . $table . '}');
  }

  /**
   * Add a new field to a table.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   Name of the table to be altered.
   * @param $field
   *   Name of the field to be added.
   * @param $spec
   *   The field specification array, as taken from a schema definition.
   */
  public function addField(&$ret, $table, $field, $spec, $keys_new = array()) {
    // TODO: $keys_new is not supported yet.
    $query = 'ALTER TABLE {' . $table . '} ADD ';
    $query .= $this->createFieldSql($field, $this->processField($spec));
    $ret[] = update_sql($query);
  }

  /**
   * Create a table with a new schema containing the old content.
   *
   * As SQLite does not support ALTER TABLE (with a few exceptions) it is
   * necessary to create a new table and copy over the old content.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   Name of the table to be altered.
   * @param $new_schema
   *   The new schema array for the table.
   */
  protected function alterTable(&$ret, $table, $new_schema) {
    $i = 0;
    do {
      $new_table = $table . '_' . $i++;
    } while ($this->tableExists($new_table));
    $this->createTable($ret, $new_table, $new_schema);
    $fields = implode(', ', array_keys($new_schema['fields']));
    $ret[] = update_sql('INSERT INTO {' . $new_table . "} ($fields) SELECT $fields FROM {" . $table . '}');
    $old_count = db_query('SELECT COUNT(*) FROM {' . $table . '}')->fetchField();
    $new_count = db_query('SELECT COUNT(*) FROM {' . $new_table . '}')->fetchField();
    if ($old_count == $new_count) {
      do {
        $temp_table = $table . '_' . $i++;
      } while ($this->tableExists($temp_table));
      $this->renameTable($ret, $table, $temp_table);
      $this->renameTable($ret, $new_table, $table);
      $this->dropTable($ret, $temp_table);
    }
  }

  /**
   * Find out the schema of a table.
   *
   * This function uses introspection methods provided by the database to
   * create a schema array. This is useful, for example, during update when
   * the old schema is not available.
   *
   * @param $table
   *   Name of the table.
   * @return
   *   An array representing the schema, from drupal_get_schema().
   * @see drupal_get_schema()
   */
  protected function introspectSchema($table) {
    $mapped_fields = array_flip($this->getFieldTypeMap());
    $schema = array();
    foreach (db_query("PRAGMA table_info('{" . $table . "}')") as $row) {
      if (preg_match('/^([^(]+)\((.*)\)$/', $row->type, $matches)) {
        $type = $matches[1];
        $length = $matches[2];
      }
      else {
        $type = $row->type;
        $length = NULL;
      }
      if (isset($mapped_fields[$type])) {
        list($type, $size) = explode(':', $mapped_fields[$type]);
        $schema['fields'][$row->name] = array(
          'type' => $type,
          'size' => $size,
          'not null' => !empty($row->notnull),
          'default' => trim($row->dflt_value, "'"),
        );
        if ($length) {
          $schema['fields'][$row->name]['length'] = $length;
        }
        if ($row->pk) {
          $schema['primary key'][] = $row->name;
        }
      }
      else {
        new Exception("Unable to parse the column type " . $row->type);
      }
    }
    $indexes = array();
    foreach (db_query("PRAGMA index_list('{" . $table . "}')") as $row) {
      if (strpos($row->name, 'sqlite_autoindex_') !== 0) {
        $indexes[] = array(
          'schema_key' => $row->unique ? 'unique keys' : 'indexes',
          'name' => $row->name,
        );
      }
    }
    $n = strlen($table) + 1;
    foreach ($indexes as $index) {
      $name = $index['name'];
      $index_name = substr($name, $n);
      foreach (db_query("PRAGMA index_info('$name')") as $row) {
        $schema[$index['schema_key']][$index_name][] = $row->name;
      }
    }
    return $schema;
  }

  /**
   * Drop a field.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $field
   *   The field to be dropped.
   */
  public function dropField(&$ret, $table, $field) {
    $new_schema = $this->introspectSchema($table);
    unset($new_schema['fields'][$field]);
    foreach ($new_schema['indexes'] as $index => $fields) {
      foreach ($fields as $key => $field_name) {
        if ($field_name == $field) {
          unset($new_schema['indexes'][$index][$key]);
        }
      }
      // If this index has no more fields then remove it.
      if (empty($new_schema['indexes'][$index])) {
        unset($new_schema['indexes'][$index]);
      }
    }
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Change a field definition.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   Name of the table.
   * @param $field
   *   Name of the field to change.
   * @param $field_new
   *   New name for the field (set to the same as $field if you don't want to change the name).
   * @param $spec
   *   The field specification for the new field.
   * @param $keys_new
   *   Optional keys and indexes specification to be created on the
   *   table along with changing the field. The format is the same as a
   *   table specification but without the 'fields' element.
   */
  public function changeField(&$ret, $table, $field, $field_new, $spec, $keys_new = array()) {
    $new_schema = $this->introspectSchema($table);
    unset($new_schema['fields'][$field]);
    $new_schema['fields'][$field_new] = $spec;
    if (isset($keys_new['primary keys'])) {
      $new_schema['primary keys'] = $keys_new['primary keys'];
      $keys_new['primary keys'];
    }
    foreach (array('unique keys', 'indexes') as $k) {
      if (!empty($keys_new[$k])) {
        $new_schema[$k] = $keys_new[$k] + $new_schema[$k];
      }
    }
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Add an index.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $name
   *   The name of the index.
   * @param $fields
   *   An array of field names.
   */
  public function addIndex(&$ret, $table, $name, $fields) {
    $schema['indexes'][$name] = $fields;
    $statements = $this->createIndexSql($table, $schema);
    foreach ($statements as $statement) {
      $ret[] = update_sql($statement);
    }
  }

  /**
   * Drop an index.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $name
   *   The name of the index.
   */
  public function dropIndex(&$ret, $table, $name) {
    $ret[] = update_sql('DROP INDEX ' . '{' . $table . '}_' . $name);
  }

  /**
   * Add a unique key.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $name
   *   The name of the key.
   * @param $fields
   *   An array of field names.
   */
  public function addUniqueKey(&$ret, $table, $name, $fields) {
    $schema['unique keys'][$name] = $fields;
    $statements = $this->createIndexSql($table, $schema);
    foreach ($statements as $statement) {
      $ret[] = update_sql($statement);
    }
  }

  /**
   * Drop a unique key.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $name
   *   The name of the key.
   */
  public function dropUniqueKey(&$ret, $table, $name) {
    $ret[] = update_sql('DROP INDEX ' . '{' . $table . '}_' . $name);
  }

  /**
   * Add a primary key.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $fields
   *   Fields for the primary key.
   */
  public function addPrimaryKey(&$ret, $table, $fields) {
    $new_schema = $this->introspectSchema($table);
    $new_schema['primary key'] = $fields;
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Drop the primary key.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.`
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   */
  public function dropPrimaryKey(&$ret, $table) {
    $new_schema = $this->introspectSchema($table);
    unset($new_schema['primary key']);
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Set the default value for a field.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $field
   *   The field to be altered.
   * @param $default
   *   Default value to be set. NULL for 'default NULL'.
   */
  public function fieldSetDefault(&$ret, $table, $field, $default) {
    $new_schema = $this->introspectSchema($table);
    $new_schema['fields'][$field]['default'] = $default;
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Set a field to have no default value.
   *
   * This implementation can't use ALTER TABLE directly, because SQLite only
   * supports a limited subset of that command.
   *
   * @param $ret
   *   Array to which query results will be added.
   * @param $table
   *   The table to be altered.
   * @param $field
   *   The field to be altered.
   */
  public function fieldSetNoDefault(&$ret, $table, $field) {
    $new_schema = $this->introspectSchema($table);
    unset($new_schema['fields'][$field]['default']);
    $this->alterTable($ret, $table, $new_schema);
  }

  /**
   * Find all tables that are like the specified base table name.
   *
   * @param $table_expression
   *   An SQL expression, for example "simpletest%" (without the quotes).
   *   BEWARE: this is not prefixed, the caller should take care of that.
   * @return
   *   Array, both the keys and the values are the matching tables.
   */
  public function findTables($table_expression) {
    // Don't use {} around sqlite_master table.
    $result = db_query("SELECT name FROM sqlite_master WHERE name LIKE :table_name", array(
      ':table_name' => $table_expression,
    ));
    return $result->fetchAllKeyed(0, 0);
  }
}
