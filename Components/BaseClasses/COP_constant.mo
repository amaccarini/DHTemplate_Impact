within DHTemplates.Components.BaseClasses;
model COP_constant "Constant, temperature-independent COP"
  extends partial_COP;

  parameter Real COP_fixed=3 "Constant COP";
equation
  COP = COP_fixed;
  annotation (Documentation(revisions="<html>
<ul>
<li>
June 19, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"));
end COP_constant;
