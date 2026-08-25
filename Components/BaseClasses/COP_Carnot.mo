within DHTemplates.Components.BaseClasses;
model COP_Carnot "Load-independent Carnot efficiency COP"
  extends partial_COP;

  parameter SI.Temperature T_hot_nominal=0.5*(T_return_nominal +
      T_supply_nominal) "Nominal average hot (DH) temperature";
  parameter Real COP_Carnot_nominal=T_hot_nominal/(T_hot_nominal -
      T_source_nominal) "Constant COP";
  parameter Real eta=COP_nominal/COP_Carnot_nominal
    "Efficiency - Carnot 'deterioration' factor";

  SI.Temperature T_hot=0.5*(T_return + T_supply) "Average hot (DH) temperature";
  Real COP_Carnot "Time-varying Carnot efficiency";
equation
  COP_Carnot = T_hot/(T_hot - T_source);
  COP = eta*COP_Carnot;
  annotation (Documentation(revisions="<html>
<ul>
<li>
June 19, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>"));
end COP_Carnot;
