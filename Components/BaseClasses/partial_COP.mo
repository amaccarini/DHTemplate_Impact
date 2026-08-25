within DHTemplates.Components.BaseClasses;
 model partial_COP
  "Defines the interface for a simple COP function"
  parameter SI.Temperature T_supply_nominal=80 + 273.15
    "Nominal supply temperature" annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_return_nominal=40 + 273.15
    "Nominal return temperature" annotation (Dialog(group="Nominal condition"));
  parameter SI.Temperature T_source_nominal=10 + 273.15
    "Nominal source temperature" annotation (Dialog(group="Nominal condition"));
  parameter Real COP_nominal=3
    "Nominal COP" annotation (Dialog(group="Nominal condition"));

  Modelica.Blocks.Interfaces.RealInput T_source(unit="K", displayUnit="degC")
    "Source temperature" annotation (Placement(transformation(extent={{-140,40},
            {-100,80}}), iconTransformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Interfaces.RealInput T_return(unit="K", displayUnit="degC")
    "District heating return temperature" annotation (Placement(transformation(
          extent={{-140,-20},{-100,20}}), iconTransformation(extent={{-140,-20},
            {-100,20}})));
  Modelica.Blocks.Interfaces.RealInput T_supply(unit="K", displayUnit="degC")
    "District heating supply temperature" annotation (Placement(transformation(
          extent={{-140,-80},{-100,-40}}), iconTransformation(extent={{-140,-80},
            {-100,-40}})));
  Modelica.Blocks.Interfaces.RealOutput COP "Coefficient of performance"
    annotation (Placement(transformation(extent={{100,-10},{120,10}}),
        iconTransformation(extent={{100,-10},{120,10}})));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=true), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-100,160},{100,120}},
          textColor={0,0,0},
          textString=DynamicSelect("", String(COP, format=".2f"))),
        Text(
          extent={{-80,40},{80,-40}},
          textColor={28,108,200},
          textString="COP")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 19, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"));
 end partial_COP;
