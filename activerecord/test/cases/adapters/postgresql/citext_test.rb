# encoding: utf-8

require 'cases/helper'
require 'active_record/base'
require 'active_record/connection_adapters/postgresql_adapter'

class PostgresqlCitextTest < ActiveRecord::TestCase
  class Citext < ActiveRecord::Base
    self.table_name = 'citexts'
  end

  def setup
    @connection = ActiveRecord::Base.connection

    unless @connection.extension_enabled?('citext')
      @connection.enable_extension 'citext'
      @connection.commit_db_transaction
    end

    @connection.reconnect!

    @connection.transaction do
      @connection.create_table('citexts') do |t|
        t.citext 'cival'
      end
    end
    @column = Citext.columns_hash['cival']
  end

  def teardown
    @connection.execute 'DROP TABLE IF EXISTS citexts;'
    @connection.execute 'DROP EXTENSION IF EXISTS citext CASCADE;'
  end

  def test_citext_enabled
    assert @connection.extension_enabled?('citext')
  end

  def test_column_type
    assert_equal :citext, @column.type
  end

  def test_column_sql_type
    assert_equal 'citext', @column.sql_type
  end

  def test_write
    x = Citext.new(cival: 'Some CI Text')
    assert x.save!
  end

  def test_select_case_insensitive
    @connection.execute "insert into citexts (cival) values('Cased Text')"
    x = Citext.where(cival: 'cased text').first
    assert_equal('Cased Text', x.cival)
  end

end