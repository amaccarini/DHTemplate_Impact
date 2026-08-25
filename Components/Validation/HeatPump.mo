within DHTemplates.Components.Validation;
model HeatPump "Validation of 'HeatPump' model"
  extends Modelica.Icons.Example;
  replaceable package Medium = Buildings.Media.Water annotation (
      choicesAllMatching=true);

  DHTemplates.Components.HeatPump heatPump(
    redeclare package Medium = Medium,
    redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=[0.0,
          0.0; 1,0.0; 1.5,heatPump.Q_flow_nominal; 8,heatPump.Q_flow_nominal; 8.5,
          0.0; 10,0.0], timeScale(displayUnit="min") = 60),
    redeclare replaceable Modelica.Blocks.Sources.TimeTable T_set(
      table=[0.0,0.0; 4,0.0; 4,-10; 6,-10; 6,0.0; 10,0.0],
      timeScale(displayUnit="min") = 60,
      offset=heatPump.T_b_nominal))
    annotation (Placement(transformation(extent={{10,-10},{30,10}})));
  Buildings.Fluid.Sources.Boundary_pT source(
    T=heatPump.T_a_nominal,
    nPorts=1,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-70,-10},{-50,10}})));
  Buildings.Fluid.Sources.Boundary_pT sink(nPorts=1, redeclare package Medium
      = Medium)
    annotation (Placement(transformation(extent={{70,10},{50,-10}})));
  Modelica.Blocks.Sources.Constant T_ambient(k=10 + 273.15, y(unit="K",
        displayUnit="degC"))
    annotation (Placement(transformation(extent={{-30,10},{-10,30}})));
  Modelica.Blocks.Sources.Constant P_set(k=10e6, y(unit="W", displayUnit="MW"))
    "Power setpoint"
    annotation (Placement(transformation(extent={{-30,-30},{-10,-10}})));
equation
  connect(source.ports[1], heatPump.port_a)
    annotation (Line(points={{-50,0},{10,0}}, color={0,127,255}));
  connect(heatPump.port_b, sink.ports[1])
    annotation (Line(points={{30,0},{50,0}}, color={0,127,255}));
  connect(T_ambient.y, heatPump.T_source_in)
    annotation (Line(points={{-9,20},{20,20},{20,12}}, color={0,0,127}));
  connect(P_set.y, heatPump.P_set_in) annotation (Line(points={{-9,-20},{0,-20},
          {0,-6},{8,-6}}, color={0,0,127}));
  annotation (
    Diagram(coordinateSystem(extent={{-80,-40},{80,40}}, grid={2,2})),
    experiment(StopTime=600, __Dymola_Algorithm="Dassl"),
    Documentation(revisions="<html>
<ul>
<li>
June 19, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>", figures={Figure(
          title="Plot results",
          plots={Plot(
            curves={Curve(
              x=time,
              y=heatPump.Q_flow,
              legend="Heat flow rate"),Curve(
              x=time,
              y=heatPump.P,
              legend="Total electric power consumption")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="MW")),Plot(
            curves={Curve(
              x=time,
              y=heatPump.T_set.y,
              legend="Supply temperature setpoint"),Curve(
              x=time,
              y=heatPump.T_b.T,
              legend="Supply temperature")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="degC")),Plot(
            curves={Curve(
              x=time,
              y=heatPump.pump.y_actual,
              legend="Pump speed")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="1")),Plot(
            curves={Curve(
              x=time,
              y=heatPump.cop.COP,
              legend="COP")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="1"))})}));
end HeatPump;
