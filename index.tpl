<!DOCTYPE html>
<html>
<head>
<style>
#customers
{
    font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
    width:50%;
    border-collapse:collapse;
}
#customers td, #customers th 
{
    font-size:1em;
    border:1px solid #98bf21;
    padding:3px 7px 2px 7px;
}
#customers th 
{
    font-size:1.1em;
    text-align:left;
    padding-top:5px;
    padding-bottom:4px;
    background-color:#A7C942;
    color:#ffffff;
}
#customers tr.alt td 
{
    color:#000000;
    background-color:#EAF2D3;
}
</style>
</head>
<body>
<h2>Available Proxy List</h2>
<table id="customers">
<tr>
<th>#</th>
<th>IP</th>
<th>Port</th>
<th>Addr</th>
</tr>
$lines
</table>
<br>
Update: $(date)<br>
Result: all: $allnum, hit: $hitnum, $hitnum / $allnum = $per %, ip: $ipnum, cost: $coststr
</body>
</html>
