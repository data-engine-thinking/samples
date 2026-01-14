/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Solution Pattern - SQL Server Family - CDC and Replication.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

EXEC sys.sp_cdc_disable_table
      @source_schema          = N'dbo',
      @source_name            = N'Employee',
      @capture_instance       = N'dbo_Employee'
 EXEC sys.sp_cdc_help_change_data_capture
