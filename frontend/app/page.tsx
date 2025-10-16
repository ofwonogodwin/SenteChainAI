'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAccount } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { motion } from 'framer-motion';
import {
    TrendingUp,
    Shield,
    Zap,
    Award,
    ArrowRight,
    DollarSign,
    Users,
    Activity
} from 'lucide-react';
import Link from 'next/link';

export default function Home() {
    const { address, isConnected } = useAccount();
    const router = useRouter();
    const [stats, setStats] = useState({
        totalUsers: 0,
        totalLoans: 0,
        avgScore: 0,
    });

    useEffect(() => {
        // Fetch platform stats
        const fetchStats = async () => {
            try {
                const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/users/stats`);
                if (response.ok) {
                    const data = await response.json();
                    setStats({
                        totalUsers: data.total_users || 0,
                        totalLoans: data.users_with_loans || 0,
                        avgScore: Math.round(data.average_credit_score) || 75,
                    });
                }
            } catch (error) {
                console.error('Failed to fetch stats:', error);
            }
        };

        fetchStats();
    }, []);

    const features = [
        {
            icon: Shield,
            title: 'AI Credit Scoring',
            description: 'Advanced machine learning algorithms analyze your on-chain behavior to generate fair credit scores.',
            gradient: 'from-blue-500 to-cyan-500',
        },
        {
            icon: Zap,
            title: 'Instant Loans',
            description: 'Get approved and receive funds instantly with our automated smart contract system.',
            gradient: 'from-purple-500 to-pink-500',
        },
        {
            icon: Award,
            title: 'Reputation NFTs',
            description: 'Earn non-transferable badges that prove your creditworthiness across DeFi.',
            gradient: 'from-orange-500 to-red-500',
        },
        {
            icon: DollarSign,
            title: 'Low Interest Rates',
            description: 'Better credit scores mean lower interest rates. Build your reputation, save money.',
            gradient: 'from-green-500 to-emerald-500',
        },
    ];

    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
            {/* Navigation */}
            <nav className="fixed top-0 w-full z-50 glass border-b border-white/10">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between items-center h-16">
                        <div className="flex items-center space-x-2">
                            <TrendingUp className="w-8 h-8 text-purple-400" />
                            <span className="text-2xl font-bold gradient-text">
                                SenteChainAI
                            </span>
                        </div>

                        <div className="flex items-center space-x-6">
                            {isConnected && (
                                <>
                                    <Link
                                        href="/dashboard"
                                        className="text-gray-300 hover:text-white transition"
                                    >
                                        Dashboard
                                    </Link>
                                    <Link
                                        href="/borrow"
                                        className="text-gray-300 hover:text-white transition"
                                    >
                                        Borrow
                                    </Link>
                                    <Link
                                        href="/lend"
                                        className="text-gray-300 hover:text-white transition"
                                    >
                                        Lend
                                    </Link>
                                </>
                            )}
                            <ConnectButton />
                        </div>
                    </div>
                </div>
            </nav>

            {/* Hero Section */}
            <section className="pt-32 pb-20 px-4">
                <div className="max-w-7xl mx-auto">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8 }}
                        className="text-center"
                    >
                        <h1 className="text-5xl md:text-7xl font-bold text-white mb-6">
                            Decentralized Lending
                            <br />
                            <span className="gradient-text">Powered by AI</span>
                        </h1>

                        <p className="text-xl md:text-2xl text-gray-300 mb-8 max-w-3xl mx-auto">
                            Build your on-chain credit score, access instant loans, and earn reputation
                            NFTs on Base blockchain.
                        </p>

                        <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                            {isConnected ? (
                                <Link
                                    href="/dashboard"
                                    className="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition flex items-center gap-2"
                                >
                                    Go to Dashboard
                                    <ArrowRight className="w-5 h-5" />
                                </Link>
                            ) : (
                                <ConnectButton.Custom>
                                    {({ openConnectModal }) => (
                                        <button
                                            onClick={openConnectModal}
                                            className="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition flex items-center gap-2"
                                        >
                                            Connect Wallet
                                            <ArrowRight className="w-5 h-5" />
                                        </button>
                                    )}
                                </ConnectButton.Custom>
                            )}

                            <a
                                href="https://github.com/yourusername/sentechainai"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="px-8 py-4 bg-white/10 text-white rounded-lg font-semibold hover:bg-white/20 transition"
                            >
                                Learn More
                            </a>
                        </div>
                    </motion.div>

                    {/* Stats */}
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, delay: 0.2 }}
                        className="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8"
                    >
                        {[
                            { icon: Users, label: 'Total Users', value: stats.totalUsers },
                            { icon: Activity, label: 'Active Loans', value: stats.totalLoans },
                            { icon: TrendingUp, label: 'Avg Score', value: stats.avgScore },
                        ].map((stat, index) => (
                            <div
                                key={index}
                                className="glass p-6 rounded-xl text-center card-hover"
                            >
                                <stat.icon className="w-12 h-12 mx-auto mb-4 text-purple-400" />
                                <div className="text-4xl font-bold text-white mb-2">
                                    {stat.value}
                                </div>
                                <div className="text-gray-400">{stat.label}</div>
                            </div>
                        ))}
                    </motion.div>
                </div>
            </section>

            {/* Features */}
            <section className="py-20 px-4">
                <div className="max-w-7xl mx-auto">
                    <motion.div
                        initial={{ opacity: 0 }}
                        whileInView={{ opacity: 1 }}
                        transition={{ duration: 0.8 }}
                        viewport={{ once: true }}
                        className="text-center mb-16"
                    >
                        <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
                            Why SenteChainAI?
                        </h2>
                        <p className="text-xl text-gray-400">
                            The future of DeFi lending is here
                        </p>
                    </motion.div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        {features.map((feature, index) => (
                            <motion.div
                                key={index}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.5, delay: index * 0.1 }}
                                viewport={{ once: true }}
                                className="glass p-8 rounded-xl card-hover"
                            >
                                <div className={`w-16 h-16 rounded-lg bg-gradient-to-br ${feature.gradient} flex items-center justify-center mb-6`}>
                                    <feature.icon className="w-8 h-8 text-white" />
                                </div>

                                <h3 className="text-2xl font-bold text-white mb-4">
                                    {feature.title}
                                </h3>

                                <p className="text-gray-400">
                                    {feature.description}
                                </p>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section className="py-20 px-4">
                <div className="max-w-4xl mx-auto">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        whileInView={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 0.8 }}
                        viewport={{ once: true }}
                        className="glass p-12 rounded-2xl text-center"
                    >
                        <h2 className="text-4xl font-bold text-white mb-6">
                            Ready to Get Started?
                        </h2>

                        <p className="text-xl text-gray-300 mb-8">
                            Connect your wallet and start building your on-chain credit today.
                        </p>

                        {!isConnected && (
                            <ConnectButton.Custom>
                                {({ openConnectModal }) => (
                                    <button
                                        onClick={openConnectModal}
                                        className="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition text-lg"
                                    >
                                        Connect Wallet Now
                                    </button>
                                )}
                            </ConnectButton.Custom>
                        )}
                    </motion.div>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-8 px-4 border-t border-white/10">
                <div className="max-w-7xl mx-auto text-center text-gray-400">
                    <p>&copy; 2025 SenteChainAI. Built with ❤️ for the future of DeFi.</p>
                </div>
            </footer>
        </div>
    );
}
