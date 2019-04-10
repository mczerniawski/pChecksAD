# Compare change results in time

```
pChecksAD_CL
| filter Name_s like 'OBJPLPDC0'
| where TimeGenerated  > ago(7d)
| where Passed_b == 'True'
| project Context_s , Passed_b , TimeGenerated , Name_s , FailureMessage_s , Target_s
| join kind=inner (
   pChecksAD_CL
   |  where Passed_b == 'False'
   | project Context_s , Passed_b , TimeGenerated , Name_s , FailureMessage_s , Target_s
   | extend TimeNew = TimeGenerated
) on Name_s
| extend TimeDifference = TimeGenerated - TimeNew
```
