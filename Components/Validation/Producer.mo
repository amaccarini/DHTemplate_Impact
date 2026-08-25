within DHTemplates.Components.Validation;
model Producer "Validation of 'Producer' model"
  extends Modelica.Icons.Example;
  replaceable package Medium = Buildings.Media.Water annotation (
      choicesAllMatching=true);

  DHTemplates.Components.Producer producer(
    redeclare package Medium = Medium,
    redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=[0.0,
          0.0; 1,0.0; 1.5,producer.Q_flow_nominal; 8,producer.Q_flow_nominal; 8.5,
          0.0; 10,0.0], timeScale(displayUnit="min") = 60),
    redeclare replaceable Modelica.Blocks.Sources.TimeTable T_set(
      table=[0.0,0.0; 4,0.0; 4,-10; 5,-10; 5,0.0; 10,0.0],
      timeScale(displayUnit="min") = 60,
      offset=producer.T_b_nominal))
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Fluid.Sources.Boundary_pT source(
    T=producer.T_a_nominal,
    nPorts=1,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-60,10},{-40,-10}})));
  Buildings.Fluid.Sources.Boundary_pT sink(nPorts=1, redeclare package Medium
      = Medium)
    annotation (Placement(transformation(extent={{60,10},{40,-10}})));
equation
  connect(source.ports[1], producer.port_a)
    annotation (Line(points={{-40,0},{-10,0}}, color={0,127,255}));
  connect(producer.port_b, sink.ports[1])
    annotation (Line(points={{10,0},{40,0}}, color={0,127,255}));
  annotation (
    Diagram(coordinateSystem(extent={{-80,-40},{80,40}}, grid={2,2})),
    experiment(StopTime=600, __Dymola_Algorithm="Dassl"),
    Documentation(revisions="<html>
<ul>
<li>
June 1, 2026, by Rene Just Nielsen:<br>
Plot script updated.
</li>
<li>
April 27, 2026, by Rene Just Nielsen:<br>
Heat flow rate and temperature steps + plot script.
</li>
<li>
April 15, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>", figures={Figure(
          title="Plot results",
          plots={Plot(
            title="Plot results",
            curves={Curve(
              x=time,
              y=producer.pid.u_s,
              legend="Heat flow rate setpoint"),Curve(
              x=time,
              y=producer.pid.u_m,
              legend="Heat flow rate")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="MW")),Plot(
            curves={Curve(
              x=time,
              y=producer.T_set.y,
              legend="Outlet temperature setpoint"),Curve(
              x=time,
              y=producer.T_b.T,
              legend="Outlet temperature")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="degC"))})}));
end Producer;
