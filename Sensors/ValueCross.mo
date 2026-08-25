within DHTemplates.Sensors;
model ValueCross
  "Displays pressure, temperature, mass flow rate, and specific enthalpy"

  parameter String format_p=".2f" "Format string for pressure";
  parameter String format_T=".1f" "Format string for temperature";
  parameter String format_m=".1f" "Format string for mass flow rate";
  parameter String format_h=".1f" "Format string for specific enthalpy";

  Modelica.Blocks.Interfaces.RealOutput p(unit="Pa", displayUnit="bar");
  Modelica.Blocks.Interfaces.RealOutput T(unit="K", displayUnit="degC");
  Modelica.Blocks.Interfaces.RealOutput m_flow(unit="kg/s");
  Modelica.Blocks.Interfaces.RealOutput h(unit="J/kg", displayUnit="kJ/kg");

  DHTemplates.Interfaces.MultiSensorPort multiSensorPort annotation (Placement(
        transformation(extent={{-20,20},{20,-20}}), iconTransformation(extent={{
            -10,-10},{10,10}})));
equation
  connect(p, multiSensorPort.p);
  connect(T, multiSensorPort.T);
  connect(m_flow, multiSensorPort.m_flow);
  connect(h, multiSensorPort.h);

  annotation (
    Icon(coordinateSystem(extent={{-140,-100},{140,100}}, grid={2,2}), graphics
        ={
        Text(
          extent={{-140,52},{-6,8}},
          textColor={0,0,0},
          textString=DynamicSelect("p", String(p*1e-5, format=format_p))),
        Text(
          extent={{6,52},{140,8}},
          textColor={0,0,0},
          textString=DynamicSelect("T", String(T - 273.15, format=format_T))),
        Text(
          extent={{-140,-8},{-6,-52}},
          textColor=DynamicSelect({0,0,0}, if m_flow < 0 then {255,0,0} else {0,
              0,0}),
          textString=DynamicSelect("m", String(m_flow, format=format_m))),
        Text(
          extent={{6,-8},{140,-52}},
          textColor={0,0,0},
          textString=DynamicSelect("h", String(h*1e-3, format=format_h))),
        Line(points={{0,60},{0,-60}}, color={0,0,0}),
        Line(points={{140,0},{-140,0}}, color={0,0,0})}),
    Diagram(coordinateSystem(extent={{-140,-100},{140,100}})),
    Documentation(revisions="<html>
<ul>
<li>
August 20, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"));
end ValueCross;
