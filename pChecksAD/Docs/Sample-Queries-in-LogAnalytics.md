# Sample queries

## Compare change results in time

```KQL
let Passed = (
pChecksAD_CL
| where TimeGenerated  > ago(7d) and Passed_b == 'True'
| project Describe_s, Context_s ,
          Passed_bTrue=Passed_b  ,
          TimeGeneratedPassed = TimeGenerated ,
          Name_s , FailureMessage_s , Target_s
);
let Failed = (
pChecksAD_CL
   | where TimeGenerated  > ago(7d) and Passed_b == 'False'
   | project Describe_s, Context_s ,
            Passed_bFalse = Passed_b ,
            TimeGeneratedFalse = TimeGenerated,
            Name_s , FailureMessage_s , Target_s
);
Passed | join kind=inner Failed on Name_s
| extend HowLongAgoH = ( now() - TimeGeneratedPassed )/ 1h,
         HowLongAgoD = ( now() - TimeGeneratedPassed )/ 1d
| project Describe_s, Context_s ,  Name_s , FailureMessage_s ,Passed_bTrue , Passed_bFalse,
          Target_s, TimeGeneratedPassed, TimeGeneratedFalse,
          ChecksTimeDifference = TimeGeneratedPassed - TimeGeneratedFalse,
          HowLongAgoH, HowLongAgoD
| sort by HowLongAgoH asc
```

## Passed and failed checks

```KQL
pChecksAD_CL
| where TimeGenerated > ago(7d)
| extend DayGenerated = startofday(TimeGenerated)
| summarize ChecksPassed = count(Passed_b=='True')
            by DayGenerated, bin(TimeGenerated,1h),
            Describe_s, Context_s
| sort by bin(TimeGenerated,1h) desc, ChecksPassed
| where ChecksPassed  <> 0
| project ChecksPassed,
          format_datetime(DayGenerated, 'yyyy/MM/dd') ,
          format_datetime(TimeGenerated, 'yyyy/MM/dd HH:mm:ss') ,
          Describe_s , Context_s



pChecksAD_CL
| where TimeGenerated between ( ago(7d) .. ago(2d) )
| extend DayGenerated = startofday(TimeGenerated)
| project Describe_s , Context_s , Name_s , Passed_b , DayGenerated , TimeGenerated
| summarize ChecksFailed = count(Passed_b=='False')
            by DayGenerated, bin(TimeGenerated,1h),
            Describe_s, Context_s
| sort by bin(TimeGenerated,1h) desc, ChecksFailed
| where ChecksFailed <> 0
| project ChecksFailed ,
          format_datetime(DayGenerated, 'yyyy/MM/dd') ,
          format_datetime(TimeGenerated, 'yyyy/MM/dd HH:mm:ss') ,
          Describe_s , Context_s


pChecksAD_CL
| where TimeGenerated > ago(7d)
| extend DayGenerated = startofday(TimeGenerated)
| summarize ChecksPassed = count(Passed_b=='True') ,
            ChecksFailed = count(Passed_b=='False')
            by DayGenerated, bin(TimeGenerated,1h) ,
            Describe_s, Context_s
| sort by bin(TimeGenerated,1h) desc, ChecksPassed, ChecksFailed
| where ChecksPassed  <> 0 and
        ChecksFailed  <> 0
| project ChecksPassed, ChecksFailed ,
          format_datetime(DayGenerated, 'yyyy/MM/dd') ,
          format_datetime(TimeGenerated, 'yyyy/MM/dd HH:mm:ss') ,
          Describe_s , Context_s

pChecksAD_CL
| where TimeGenerated > ago(7d)
| project Describe_s ,Context_s, Name_s , Passed_b
| evaluate pivot(Passed_b)
| sort by Describe_s
```

## Passed and failed statistics

```KQL
pChecksAD_CL
| where TimeGenerated > ago(7d)
| summarize ChecksPassed = (count(Passed_b == 'True')),
         ChecksFailed = (count(Passed_b == 'False'))
         by Describe_s
| sort by ChecksFailed
```