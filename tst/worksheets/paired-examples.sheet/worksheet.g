#! @Title Paired Examples Test
#! @Date 2026-03-07
#! @Chapter Examples Chapter
#! @Section Examples Section
#! This worksheet exercises example and log commands in comment mode.

#! @Subsection Tested examples
#! @BeginExample
comment_example_value := 2 + 3;
#! 5
#! @EndExample

#! @Example
comment_alias_example := 3 + 4;
#! 7
#! @EndExample

#! @BeginExampleSession
#! gap> 10 - 3;
#! 7
#! @EndExampleSession

#! @ExampleSession
#! gap> 6 * 7;
#! 42
#! @EndExampleSession

#! @Subsection Untested logs
#! @BeginLog
comment_log_value := 9;
#! 9
#! @EndLog

#! @Log
comment_alias_log := 11;
#! 11
#! @EndLog

#! @BeginLogSession
#! gap> "comment log session";
#! "comment log session"
#! @EndLogSession

#! @LogSession
#! gap> "comment alias log session";
#! "comment alias log session"
#! @EndLogSession
