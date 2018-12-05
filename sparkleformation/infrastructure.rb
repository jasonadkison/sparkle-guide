SparkleFormation.new(:infrastructure) do
  nest!(:network, :infra)
  nest!(:computes, :infra)
end
