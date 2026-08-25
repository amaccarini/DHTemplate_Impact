within ;
package DHTemplates
  "Library of district heating templates for Modelica'2027 paper"
  extends Modelica.Icons.Package;
  import Modelica.Units.SI;

  annotation (
    uses(Modelica(version="4.1.0"), Buildings(version="13.0.0"),
      Rankine(version="1.1.6")),
    Icon(graphics={
        Polygon(
          points={{-60,82},{20,82},{60,42},{60,-78},{-60,-78},{-60,82}},
          lineColor={135,135,135},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{20,82},{20,42},{60,42}}, color={135,135,135}),
        Polygon(
          points={{-48,22},{32,22},{32,28},{52,20},{32,12},{32,18},{-48,18},{-48,
              22}},
          lineColor={135,135,135},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{52,-18},{-28,-18},{-28,-12},{-48,-20},{-28,-28},{-28,-22},{52,
              -22},{52,-18}},
          lineColor={135,135,135},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None)}),
    Documentation(revisions="<html>
<ul>
<li>
May 7, 2026, by Rene Just Nielsen:<br>
Updated MBL library version to 13.0.0.
</li>
<li>
April 15, 2026, by Rene Just Nielsen:<br>
Package created.
</li>
</ul>
</html>"));
end DHTemplates;
