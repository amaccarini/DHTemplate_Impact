within DHTemplates.Components.Validation;
model HeatStorageTank "Validation of 'HeatStorageTank' model"
  extends Modelica.Icons.Example;
  replaceable package Medium = Buildings.Media.Water annotation (
      choicesAllMatching=true);

  DHTemplates.Components.Producer producer(
    redeclare package Medium = Medium,
    Q_flow_nominal=60000000,
    redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=[0.0,
          producer.Q_flow_nominal; 20,producer.Q_flow_nominal; 20,0; 60,0],
        timeScale(displayUnit="min") = 60)) annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-90,0})));
  DHTemplates.Components.Consumer consumer(redeclare package Medium = Medium,
      redeclare replaceable Modelica.Blocks.Sources.TimeTable Q_flow_set(table=[
          0.0,consumer.Q_flow_nominal; 40,consumer.Q_flow_nominal; 40,0.1*
          consumer.Q_flow_nominal; 60,0.1*consumer.Q_flow_nominal], timeScale(
          displayUnit="min") = 60))         annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={90,0})));
  DHTemplates.Components.HeatStorageTank heatStorageTank(redeclare package
      Medium = Medium)
    annotation (Placement(transformation(extent={{-60,-20},{-20,20}})));
  Buildings.Fluid.Movers.SpeedControlled_y pump(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=2*{0,consumer.m_flow_nominal/rho_nominal,1.5*consumer.m_flow_nominal
            /rho_nominal}, dp=2*{2*consumer.dp_nominal,consumer.dp_nominal,0})))
    "DH supply pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={50,50})));
  replaceable Buildings.Controls.Continuous.LimPID pid(
    k=2/1e5,
    Ti=10,
    u_s(unit="Pa", displayUnit="bar"),
    u_m(unit="Pa", displayUnit="bar")) "Differential pressure controller"
    annotation (Dialog(group="Heat flow rate control"), Placement(
        transformation(extent={{20,-10},{40,10}})));
  Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium
      = Medium) annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={70,0})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={producer.m_flow_nominal,-consumer.m_flow_nominal,-
        heatStorageTank.m_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-44,46},{-36,54}})));
  replaceable Modelica.Blocks.Sources.Constant dp_set(k=consumer.dp_nominal)
    constrainedby Modelica.Blocks.Interfaces.SO(y(unit="Pa", displayUnit="bar"))
    "Differential pressure setpoint" annotation (
    Dialog(group="Heat flow rate control"),
    Placement(transformation(extent={{-10,-10},{10,10}})),
    choicesAllMatching=true);
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal={consumer.m_flow_nominal,-producer.m_flow_nominal,
        heatStorageTank.m_flow_nominal},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={-40,-50})));
protected
  parameter Medium.Density rho_nominal=Medium.density_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default);
equation
  connect(senRelPre.port_a, consumer.port_a) annotation (Line(points={{70,6},{70,
          20},{90,20},{90,10}}, color={0,127,255}));
  connect(senRelPre.port_b, consumer.port_b) annotation (Line(points={{70,-6},{70,
          -20},{90,-20},{90,-10}}, color={0,127,255}));
  connect(dp_set.y, pid.u_s)
    annotation (Line(points={{11,0},{18,0}}, color={0,0,127}));
  connect(pid.y, pump.y)
    annotation (Line(points={{41,0},{50,0},{50,38}}, color={0,0,127}));
  connect(pump.port_b, consumer.port_a)
    annotation (Line(points={{60,50},{90,50},{90,10}}, color={0,127,255}));
  connect(senRelPre.p_rel, pid.u_m) annotation (Line(points={{64.6,0},{60,0},{60,
          -32},{30,-32},{30,-12}}, color={0,0,127}));
  connect(producer.port_b, jun.port_1)
    annotation (Line(points={{-90,10},{-90,50},{-44,50}}, color={0,127,255}));
  connect(jun.port_3, heatStorageTank.port_a)
    annotation (Line(points={{-40,46},{-40,20}}, color={0,127,255}));
  connect(heatStorageTank.port_b, jun1.port_3)
    annotation (Line(points={{-40,-20},{-40,-46}}, color={0,127,255}));
  connect(jun1.port_2, producer.port_a) annotation (Line(points={{-44,-50},{-90,
          -50},{-90,-10}}, color={0,127,255}));
  connect(jun1.port_1, consumer.port_b)
    annotation (Line(points={{-36,-50},{90,-50},{90,-10}}, color={0,127,255}));
  connect(pump.port_a, jun.port_2)
    annotation (Line(points={{40,50},{-36,50}}, color={0,127,255}));
  annotation (
    Diagram(coordinateSystem(extent={{-100,-60},{100,60}}, grid={2,2})),
    experiment(StopTime=3600, __Dymola_Algorithm="Dassl"),
    Documentation(revisions="<html>
<ul>
<li>
May 20, 2026, by Rene Just Nielsen:<br>
First implementation.
</li>
</ul>
</html>", figures={Figure(
          title="Plot results",
          plots={Plot(
            title="Plot 1",
            curves={Curve(
              x=time,
              y=producer.Q_flow,
              legend="Heat production"),Curve(
              x=time,
              y=consumer.Q_flow,
              legend="Heat consumption"),Curve(
              x=time,
              y=heatStorageTank.Q_flow,
              legend="Heat storage charge rate")},
            x=Axis(label="", unit="min"),
            y=Axis(label="", unit="MW")),Plot(
            curves={Curve(
              x=time,
              y=pid.u_s,
              legend="Differential pressure setpoint"),Curve(
              x=time,
              y=pid.u_m,
              legend="Differential pressure"),Curve(
              x=time,
              y=pump.y_actual,
              legend="Pump speed")},
            x=Axis(label="", unit="min"))})}));
end HeatStorageTank;
