import Topic from "../models/Topic";
import { normalizeTrendStatus } from "../utils/analytics";

export class TopicService {
  static async getAllTopics(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const topics = await Topic.find()
      .populate("analysisRunId")
      .populate("papers")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await Topic.countDocuments();

    return {
      topics,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getTopicById(id: string) {
    const topic = await Topic.findById(id)
      .populate("analysisRunId")
      .populate("papers");

    if (!topic) {
      throw { status: 404, message: "Topic not found" };
    }

    return topic;
  }

  static async createTopic(topicData: any) {
    const topic = new Topic(topicData);
    await topic.save();
    await topic.populate(["analysisRunId", "papers"]);
    return topic;
  }

  static async updateTopic(id: string, topicData: any) {
    const topic = await Topic.findByIdAndUpdate(id, topicData, {
      new: true,
    }).populate(["analysisRunId", "papers"]);

    if (!topic) {
      throw { status: 404, message: "Topic not found" };
    }

    return topic;
  }

  static async deleteTopic(id: string) {
    const topic = await Topic.findByIdAndDelete(id);

    if (!topic) {
      throw { status: 404, message: "Topic not found" };
    }

    return topic;
  }

  static async getEmergingTopics() {
    const topics = await Topic.find({ isEmerging: true })
      .populate("analysisRunId")
      .populate("papers")
      .sort({ createdAt: -1 });

    return topics;
  }

  static async analyzeTrendStatus(yearlyData: Map<string, number>) {
    const years = Array.from(yearlyData.keys()).sort(
      (a, b) => Number(a) - Number(b),
    );
    if (years.length < 2) return "stable";

    const firstYear = years[0];
    const lastYear = years[years.length - 1];
    const firstValue = yearlyData.get(firstYear) ?? 0;
    const lastValue = yearlyData.get(lastYear) ?? 0;
    const yearSpan = Math.max(1, Number(lastYear) - Number(firstYear));

    const growthRate =
      firstValue === 0
        ? 0
        : ((lastValue - firstValue) / firstValue) * (100 / yearSpan);
    return normalizeTrendStatus(growthRate);
  }

  static async updateTrendStatus(id: string) {
    const topic = await Topic.findById(id);
    if (!topic) {
      throw { status: 404, message: "Topic not found" };
    }

    topic.trendStatus = await this.analyzeTrendStatus(topic.yearlyData);
    topic.isEmerging = topic.trendStatus === "emerging";
    await topic.save();

    return topic;
  }
}
