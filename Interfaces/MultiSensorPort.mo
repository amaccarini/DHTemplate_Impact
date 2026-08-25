within DHTemplates.Interfaces;
expandable connector MultiSensorPort
  "Expandable connector for communicating measured quantities from MultiSensor to ValueCross"
  SI.Pressure p;
  SI.Temperature T;
  SI.MassFlowRate m_flow;
  SI.SpecificEnthalpy h;

  annotation (Icon(coordinateSystem(preserveAspectRatio=true), graphics={
        Rectangle(
          extent={{-2,2},{2,-2}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.Solid,
          thickness=0),
        Polygon(
          points={{0,100},{-100,0},{0,-100},{100,0},{0,100}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{0,40},{-40,0},{0,-40},{40,0},{0,40}},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None)}), Diagram(coordinateSystem(
          preserveAspectRatio=true)),
    Documentation(revisions="<html>
<ul>
<li>
August 20, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"));
end MultiSensorPort;
